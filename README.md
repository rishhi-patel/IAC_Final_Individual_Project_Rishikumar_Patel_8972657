# PROG 8870 — Final Individual Project (AWS IaC)

**Student:** Rishikumar Patel · **ID:** 8972657

This repository delivers exactly what the brief requires—no extras—implemented in **Terraform** and **CloudFormation** with your tags applied to all resources.

## Repository Layout

```
aws-iac-final/
├─ terraform/
│  ├─ provider.tf
│  ├─ backend.tf
│  ├─ variables.tf
│  ├─ main.tf
│  └─ terraform.tfvars
├─ cloudformation/
│  ├─ s3.yaml                 # 3 S3 buckets (private + versioning + PAB)
│  ├─ ec2.yaml                # EC2 with its own VPC, subnet, SG(22)
│  └─ rds.yaml                # RDS MySQL (public for demo), VPC + subnets + SG(3306)
└─ README.md
```

---

## Terraform (VPC, 4×S3, EC2, RDS)

1. Copy the `terraform/` folder contents into your repo.
2. Edit `terraform/terraform.tfvars` with your values (sample below). Ensure **four** globally unique S3 names.
3. Initialize and apply:

```bash
cd terraform
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve
```

### Sample `terraform.tfvars`

```hcl
# === Student tags ===
student_name = "Rishikumar Patel"
student_id   = "8972657"

# === Region ===
region = "us-east-1"

# === S3 (exactly 4 unique bucket names) ===
s3_bucket_names = [
  "rishikumar-8972657-prog8870-a-20250812",
  "rishikumar-8972657-prog8870-b-20250812",
  "rishikumar-8972657-prog8870-c-20250812",
  "rishikumar-8972657-prog8870-d-20250812",
]

# === EC2 ===
ami_id        = "ami-0c55b159cbfafe1f0"
instance_type = "t3.micro"
key_name      = ""

# === VPC/Subnets ===
vpc_cidr            = "10.0.0.0/16"
public_subnet1_cidr = "10.0.1.0/24"
public_subnet2_cidr = "10.0.2.0/24"

# === RDS (MySQL) ===
db_name              = "appdb"
db_username          = "adminuser"
db_password          = "gR8!pA55w0rd_2024"
db_allocated_storage = 20
```

### Expected Terraform Outputs

- `s3_bucket_names` — list of 4 buckets created
- `ec2_public_ip` — public IP of EC2 instance
- `rds_endpoint` — DNS endpoint of RDS instance

### Terraform Cleanup

```bash
terraform destroy -var-file="terraform.tfvars"
```

---

## CloudFormation (S3 ×3, EC2, RDS)

Each template is self-contained and tags resources with your name and ID.

### Deploy S3 (3 buckets: private + versioning + PublicAccessBlock)

```bash
aws cloudformation deploy   --template-file cloudformation/s3.yaml   --stack-name cf-s3-buckets   --parameter-overrides     StudentName="Rishikumar Patel"     StudentID="8972657"     Bucket1Name="rishikumar-8972657-prog8870-a-20250812"     Bucket2Name="rishikumar-8972657-prog8870-b-20250812"     Bucket3Name="rishikumar-8972657-prog8870-c-20250812"   --capabilities CAPABILITY_NAMED_IAM
```

### Deploy EC2 (with its own VPC, public subnet, SSH allowed)

```bash
aws cloudformation deploy   --template-file cloudformation/ec2.yaml   --stack-name cf-ec2   --parameter-overrides     StudentName="Rishikumar Patel"     StudentID="8972657"     AmiId="ami-0c55b159cbfafe1f0"     InstanceType="t3.micro"     KeyName=""   --capabilities CAPABILITY_NAMED_IAM
```

**Output:** `InstancePublicIp`

### Deploy RDS MySQL (public for demo) with VPC + 2 public subnets

```bash
aws cloudformation deploy   --template-file cloudformation/rds.yaml   --stack-name cf-rds   --parameter-overrides     StudentName="Rishikumar Patel"     StudentID="8972657"     DBName="appdb"     MasterUsername="adminuser"     MasterUserPassword="gR8!pA55w0rd_2024"   --capabilities CAPABILITY_NAMED_IAM
```

**Outputs:** `DBEndpoint`, `DBPort`

### CloudFormation Cleanup

```bash
aws cloudformation delete-stack --stack-name cf-s3-buckets
aws cloudformation delete-stack --stack-name cf-ec2
aws cloudformation delete-stack --stack-name cf-rds
```

---

## Validation Checklist (terraform)

- ✅ **Terraform:** CLI output of `terraform apply` and **Outputs** block.
<img width="2560" height="1600" alt="image" src="https://github.com/user-attachments/assets/27238552-5c26-4580-8541-d5a5e30ff437" />

<img width="2560" height="1600" alt="image" src="https://github.com/user-attachments/assets/d3bf8170-847b-464d-bd91-c3644d82db34" />


- ✅ **S3:** Four TF buckets and three CFN buckets with **Versioning: Enabled** and **Public access blocked**.

<img width="2560" height="1600" alt="image" src="https://github.com/user-attachments/assets/4bfbc181-25f3-46da-9e4e-4023c2ad6f87" />


- ✅ **EC2:** Instance in custom VPC with **Public IP** visible; SG allows **SSH (22)**.
<img width="2560" height="1600" alt="image" src="https://github.com/user-attachments/assets/0db5f954-d239-421c-a412-bb800f89d9bd" />

- ✅ **RDS:** MySQL instance **available** with public endpoint visible.

<img width="2560" height="1600" alt="image" src="https://github.com/user-attachments/assets/eb2dfd4d-d65f-4690-8b7a-15a3803720e5" />

