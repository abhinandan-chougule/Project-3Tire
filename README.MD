# 🏗️ AWS 3-Tier Infrastructure with Terraform

## 📌 Overview

This repository contains **production-ready Terraform infrastructure code** for deploying a **highly available, scalable 3-tier application** on AWS. It automates the provisioning of networking, compute, database, and monitoring resources with best practices for security, auto-scaling, and observability.

### Architecture Highlights

- **Multi-AZ Deployment** with public, private (app), and private (database) subnets
- **Application Load Balancer (ALB)** for traffic distribution and HTTPS termination
- **Auto Scaling Group (ASG)** for dynamic EC2 instance management
- **RDS MySQL Database** with Multi-AZ for high availability
- **Route 53** for DNS management and HTTPS certificate provisioning
- **CloudWatch & SNS** for monitoring, alarms, and notifications
- **S3 Artifacts Bucket** for application binary storage
- **Bastion Host** for secure database access
- **IAM Roles** for secure EC2 instance access via Systems Manager

---

## 📂 Project Structure

```
aws-infra-build/
├── main.tf                  # Primary resource definitions
├── variables.tf             # Input variables and defaults
├── outputs.tf               # Output values for reference
├── providers.tf             # AWS provider configuration
├── versions.tf              # Terraform & provider versions
├── backend.tf               # Remote state configuration
├── prod.tfvars              # Production variable values (create from template)
├── prod.tfvars.template     # Template for prod.tfvars
├── README.md                # This file
├── modules/                 # Reusable Terraform modules
│   ├── vpc/                 # VPC, subnets, security groups, route tables
│   ├── alb/                 # Application Load Balancer & target groups
│   ├── app-asg/             # Auto Scaling Group & Launch Templates
│   ├── bastion/             # Bastion host for secure access
│   ├── rds/                 # RDS MySQL database
│   ├── route53/             # Route 53 hosted zone & ACM certificates
│   ├── s3-artifacts/        # S3 bucket for application artifacts
│   ├── monitoring/          # CloudWatch alarms & SNS topics
│   └── secrets/             # Secrets management (if applicable)
└── docs/                    # Documentation
    ├── architecture.md      # Architecture diagram & details
    └── demo_video.md        # Video walkthrough references
```

---

## 📋 Key Modules

| Module | Description | Resources |
|--------|-------------|-----------|
| **vpc** | Network foundation with multi-AZ subnets | VPC, Subnets, Route Tables, NACLs, Security Groups |
| **alb** | HTTP/HTTPS traffic distribution | ALB, Target Groups, Listeners, Security Groups |
| **app-asg** | Auto-scaling compute layer | Auto Scaling Group, Launch Template, IAM Roles |
| **bastion** | Secure administrative access | EC2 Instance, Security Group, EIP |
| **rds** | Managed relational database | RDS Instance, DB Subnet Group, Security Group |
| **route53** | DNS & SSL/TLS certificate management | Hosted Zone, DNS Records, ACM Certificates |
| **s3-artifacts** | Application binary storage | S3 Bucket, Bucket Policies, Lifecycle Rules |
| **monitoring** | Observability & alerting | CloudWatch Alarms, SNS Topics, Log Groups |

---

## 🚀 Quick Start

### Prerequisites

- AWS Account with appropriate IAM permissions
- Terraform >= 1.0 installed locally
- AWS CLI configured with credentials
- A registered domain (optional, but recommended for HTTPS)
- Java 17+ for building the Spring Boot application

### Step 1: Prepare Configuration

```bash
# Clone the infrastructure repository
git clone https://github.com/abhinandan-chougule/aws-3tier-infra-build.git
cd aws-3tier-infra-build

# Also clone the application repository for reference
git clone https://github.com/abhinandan-chougule/spring-boot-petclinic-code.git
```

### Step 2: Configure AWS Credentials

Create or use existing IAM user credentials with AdministratorAccess (for production, use least-privilege policies, refer notes for HOW TO CREATE):

```bash
# Option A: Use AWS CLI profiles
aws configure --profile terraform-admin

# Option B: Set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="ap-southeast-1"

# Verify connectivity
aws sts get-caller-identity --profile terraform-admin
```

### Step 3: Configure Terraform Variables

```bash
# Create production variables file from template
cp prod.tfvars.template prod.tfvars

# Edit with your environment-specific values
# Key variables to update:
# - project_name: Unique name for your resources
# - domain_name: Your Route 53 hosted zone domain
# - hosted_zone_id: Route 53 hosted zone ID
# - vpc_cidr, public_subnet_cidrs, private_app_subnet_cidrs, private_db_subnet_cidrs
# - db_username, db_password
# - instance_type, desired_capacity, min_size, max_size
```

### Step 4: Plan and Deploy Infrastructure

```bash
# Initialize Terraform (downloads modules & providers)
terraform init

# Review planned changes
terraform plan -var-file=prod.tfvars -out=tfplan

# Apply the configuration
terraform apply tfplan
```

---

## 🔧 Configuration Details

### Security Groups

- **ALB Security Group**: Allows HTTP (80) and HTTPS (443) from anywhere (0.0.0.0/0)
- **App Security Group**: Allows port 8080 from ALB; SSH from bastion
- **Bastion Security Group**: Allows SSH (22) from admin CIDR
- **RDS Security Group**: Allows MySQL (3306) from app tier only

### Auto Scaling Configuration

- **Min Instances**: 2 (high availability across AZs)
- **Desired Capacity**: 3 (default, adjustable)
- **Max Instances**: 6 (scale-out limit)
- **Scale-Up Trigger**: CPU ≥ 70% for 5 minutes
- **Scale-Down Trigger**: CPU ≤ 30% for 10 minutes

### CloudWatch Monitoring

Automated alarms for:
- **High CPU Usage** (≥ 75%) → SNS notification
- **Unhealthy Targets** in ALB → SNS notification
- **RDS Database CPU** (≥ 80%) → SNS notification
- **RDS Free Storage** (< 10%) → SNS notification

---

## 📊 Outputs

After applying Terraform, key outputs are displayed:

```bash
terraform output
```

**Important Outputs:**
- `alb_dns_name` - Application Load Balancer DNS
- `alb_arn` - ALB ARN for reference
- `asg_name` - Auto Scaling Group name
- `rds_endpoint` - RDS database endpoint
- `rds_port` - RDS port (default 3306)
- `bastion_public_ip` - Bastion host IP
- `artifacts_bucket_name` - S3 bucket for application JAR
- `cloudwatch_sns_topic_arn` - SNS topic for alerts
- `certificate_arn` - ACM certificate ARN


---

### Step 5: Build and Deploy Application

**Option A: Use Pre-built JAR**
```bash
# Download from repository artifacts
aws s3 cp s3://your-artifacts-bucket/spring-petclinic.jar ./
```

**Option B: Build Locally**
```bash
cd ../spring-boot-petclinic-code

# Build with Maven/Gradle (skip tests for faster build)
./mvnw -DskipTests package
# or
./gradlew build -x test

# Upload to S3
aws s3 cp target/spring-petclinic-*.jar s3://$(terraform output -raw artifacts_bucket_name)/spring-petclinic.jar
```

### Step 6: Verify Deployment

#### Access Database via Bastion
```bash
# EC2 instance has artifact JAR downloaded from S3 in /home/ubuntu/app.jar

# Get bastion and RDS endpoints
Navigate to AWS console, select Bastion host and connect through session manager
sudo su
mysql -h petclinic-prod-db.xxx.ap-southeast-1.rds.amazonaws.com -u appuser -p
```

#### Verify Database Schema
```sql
SHOW DATABASES;
USE petclinic;
SHOW TABLES;
SELECT * FROM owners LIMIT 10;
```
### Load Testing

Generate traffic to test auto-scaling:
On your bastion host, run:
```bash

#!/bin/bash
URL="http://petclinic-asg-1-1636220375.us-east-1.elb.amazonaws.com"
echo "Starting load test on $URL ..."

while true; do
  for i in {1..100}; do
    curl -s -o /dev/null -w "%{http_code}\n" "$URL" &
  done
  wait
done


👉 Save this as
load-test.sh, then:
chmod +x load-test.sh./load-test.sh
```bash

# Monitor auto-scaling in AWS Console
# AWS > EC2 > Auto Scaling Groups > [project-name-asg] > Activity tab
```

---

## 🛠️ Troubleshooting

### ALB returns 503 Service Unavailable

- Check if EC2 instances in ASG have started successfully
- Verify security groups allow traffic from ALB to instances on port 8080
- SSH into instance and check if Spring Boot application is running: `ps aux | grep java`
- Check CloudWatch logs: `/aws/ec2/spring-petclinic.log`

### Cannot connect to RDS from bastion

- Verify RDS security group allows MySQL (3306) from app tier security group
- Ensure bastion has internet connectivity (NAT gateway) if using private RDS
- Check RDS status in AWS Console (should be "Available")

### Terraform state lock

If locked during previous apply:
```bash
terraform force-unlock <LOCK_ID>
```

### High AWS costs

- Review ASG max_size and desired_capacity in prod.tfvars
- Check if unnecessary resources are running (unused snapshots, old volumes)
- Consider using Reserved Instances for predictable workloads

---

## 📝 Maintenance & Updates

### Regular Tasks

- **Weekly**: Monitor CloudWatch dashboards and SNS alerts
- **Monthly**: Review security group rules and update as needed
- **Quarterly**: Test disaster recovery (backup/restore RDS)
- **Annually**: Update Terraform provider versions and modules

### Updating Infrastructure

```bash
# Pull latest changes
git pull origin main

# Review planned updates
terraform plan -var-file=prod.tfvars

# Apply updates with minimal downtime
terraform apply -var-file=prod.tfvars
```

### Backup Strategy

- **RDS Automated Backups**: 7 days retention (configurable)
- **Manual Snapshots**: Create before major changes
- **Application JAR**: Stored in S3 with versioning enabled
- **Terraform State**: Stored in S3 with encryption and versioning

---

## 🧹 Cleanup

To avoid unnecessary AWS costs, destroy resources when not needed:

```bash
# Review what will be deleted
terraform plan -destroy -var-file=prod.tfvars

# Delete all resources
terraform destroy -var-file=prod.tfvars

# Confirm deletion (type 'yes' when prompted)
```

⚠️ **Warning**: This will permanently delete the database and all associated resources.

---

## 📚 Additional Resources

- [Architecture Diagram](docs/architecture.md)
- [Demo Video Walkthrough](docs/demo_video.md)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Spring PetClinic Application](https://github.com/abhinandan-chougule/spring-boot-petclinic-code)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

## 📞 Support & Contributing

For issues, improvements, or contributions:

1. Create an issue describing the problem or feature
2. Submit a pull request with changes
3. Ensure Terraform code follows best practices (use `terraform fmt`)
4. Update documentation for new features

---

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

---

**Last Updated**: January 2026  
**Maintained By**: Abhinandan Chougule  
**Terraform Version**: >= 1.0
