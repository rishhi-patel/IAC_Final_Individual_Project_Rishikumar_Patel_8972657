variable "student_name" { type = string }
variable "student_id" { type = string }

variable "region" {
  type    = string
  default = "us-east-1"
}


variable "s3_bucket_names" {
  description = "Exactly 4 unique S3 bucket names (global uniqueness required)"
  type        = list(string)
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnet1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
variable "public_subnet2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}


variable "ami_id" {
  description = "AMI ID to use for EC2 (region-specific)"
  type        = string
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "key_name" {
  description = "Optional EC2 key pair for SSH; leave empty to skip"
  type        = string
  default     = ""
}


variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_allocated_storage" {
  type    = number
  default = 20
}
