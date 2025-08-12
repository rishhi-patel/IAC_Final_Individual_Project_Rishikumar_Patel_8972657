resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "prog8870-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "prog8870-igw" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = { Name = "public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags                    = { Name = "public-b" }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "public-rt" }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_s3_bucket" "buckets" {
  for_each = toset(var.s3_bucket_names)
  bucket   = each.value
  tags     = { Name = each.value }
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = aws_s3_bucket.buckets
  bucket   = each.value.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "pab" {
  for_each                = aws_s3_bucket.buckets
  bucket                  = each.value.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


resource "aws_security_group" "ec2_sg" {
  name        = "ec2-ssh-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ec2-ssh-sg" }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg"
  description = "Allow MySQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "rds-mysql-sg" }
}


resource "aws_instance" "vm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null

  tags = { Name = "prog8870-ec2" }
}


resource "aws_db_subnet_group" "db_subnets" {
  name       = "prog8870-db-subnets"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  tags       = { Name = "prog8870-db-subnets" }
}

resource "aws_db_instance" "mysql" {
  identifier             = "prog8870-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true

  depends_on = [aws_route.internet_access]
  tags       = { Name = "prog8870-mysql" }
}


output "s3_bucket_names" {
  value = keys(aws_s3_bucket.buckets)
}

output "ec2_public_ip" {
  value = aws_instance.vm.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}
