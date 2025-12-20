# AWS Infra Build – Petclinic Project

## Overview
**Goal:** Provision a secure, scalable AWS infrastructure for the Petclinic application using Terraform.  
**Outcome:** Automated environment setup with cost‑optimized resources, reduced manual errors, and faster deployments.

## Architecture
- **Diagram:** See `docs/architecture.md`
- **Stack:** AWS, Terraform, Bash
- **Components:**
  - VPC with public/private subnets
  - Bastion host for secure access
  - RDS MySQL database
  - Application load balancer + Auto Scaling Group
  - Security groups with SG‑to‑SG rules

## Setup
- **Prereqs:**
  - AWS CLI configured (`aws configure`)
  - Terraform >= 1.5
  - Make (optional, for scripted commands)

- **Steps:**
  1. `aws configure` (set up your AWS credentials)
  2. `terraform init`
  3. `terraform plan -var-file=prod.tfvars`
  4. `terraform apply -var-file=prod.tfvars`

## Usage
- **Config:** `prod.tfvars` for production settings (CIDRs, DB creds, tags)  
- **Connect:** Use Bastion host (via SSM) to access private RDS

## Screenshots
- Add architecture diagram (`docs/architecture.md`)  
- Add screenshots of Terraform plan/apply output or AWS console resources

## License
##MIT
