# 🏗️ Production Infrastructure with Terraform + AWS

## 📌 Overview
This repository contains Terraform code to provision a **production‑ready infrastructure** on AWS.  
It automates networking, compute, monitoring, and application deployment — ensuring scalability, security, and maintainability.

### Key Features
- **Infrastructure as Code** with Terraform
- **Auto Scaling Group (ASG)** for EC2 instances
- **Application Load Balancer (ALB)** in public subnets
- **Internet Gateway (IGW)** for internet access
- **RDS schema bootstrap** (`petclinic` database + privileges)
- **Artifact download from S3** (Spring Boot JAR)
- **CloudWatch monitoring & SNS alerts** (CPU ≥ 60%, unhealthy hosts)

---

## ⚙️ Modules

| Module        | Purpose                                      |
|---------------|----------------------------------------------|
| **vpc**       | Creates VPC, subnets, and networking         |
| **ig**        | Internet Gateway + public route tables       |
| **alb**       | Application Load Balancer + Target Groups    |
| **asg**       | Auto Scaling Group + Launch Template for EC2 |
| **monitoring**| CloudWatch alarms + SNS topic/subscription   |

---

## 🚀 Usage

### 1. Clone the repo
```bash

git clone https://github.com/abhinandan-chougule/aws-3tier-infra-build.git

and

git clone https://github.com/abhinandan-chougule/spring-boot-petclinic-code.git

2. Configure parameters
Rename prod.tfvars.template → prod.tfvars and update parameters.

If you have your own domain, add it in Route53 and create a hosted zone to replicate a real-world scenario with HTTPS access.

Create the terraform-admin credentials or use your own in providers.tf (refer to Notes for setup).

3. Verify AWS account connectivity
bash
aws sts get-caller-identity --profile terraform-admin
4. Run Terraform commands
bash
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
terraform destroy -var-file=prod.tfvars
5. Upload JAR file to S3
Option A – Upload the ready-made spring-petclinic.jar from the infra repo to S3.
Option B – Build locally with Maven:

bash
./mvnw -DskipTests package
If Java is not installed:

bash
sudo apt install -y openjdk-17-jdk-headless
./mvnw -DskipTests package
Upload to S3:

bash
aws s3 cp target/spring-petclinic-*.jar s3://mypro-artifacts-prod/spring-petclinic.jar
6. Verify Terraform apply
Check outputs and logs for errors.

7. Connect to RDS via Bastion
bash
sudo su
mysql -h <rds-endpoint> -u <db-username> -p
Example:

bash
mysql -h petclinic-prod-db.cj6xxxxxx0w.ap-southeast-1.rds.amazonaws.com -u appuser -p
Verify schema:

sql
SHOW DATABASES;
USE petclinic;
SHOW TABLES;
SELECT * FROM owners LIMIT 50;
8. Test application
Add a new owner in the UI.

Confirm entry in RDS using SQL queries above.

9. Load testing
Run stress tests to validate scaling and monitoring.