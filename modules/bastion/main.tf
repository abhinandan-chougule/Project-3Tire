# ===== Get latest Amazon Linux 2 AMI =====
data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ===== Bastion IAM Role for SSM =====
resource "aws_iam_role" "bastion_ssm" {
  name_prefix = "${var.project_name}-bastion-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.project_name}-bastion-role" })
}

# ===== Attach SSM Core Policy =====
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.bastion_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ===== Instance Profile =====
resource "aws_iam_instance_profile" "bastion_profile" {
  name_prefix = "${var.project_name}-bastion-"
  role        = aws_iam_role.bastion_ssm.name
}

# ===== Bastion Security Group =====
resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-bastion-sg-"
  description = "Allow SSH from admin CIDR"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-bastion-sg" })
}

# ===== Bastion EC2 Instance =====
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux2.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  associate_public_ip_address = true
  key_name               = var.ec2_key_name
  iam_instance_profile   = aws_iam_instance_profile.bastion_profile.name

  vpc_security_group_ids = [aws_security_group.bastion.id]
  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Install or update EC2 Instance Connect
              yum install -y ec2-instance-connect

              # Ensure SSH service is running
              systemctl enable sshd
              systemctl restart sshd
              EOF
  tags = merge(var.tags, { Name = "${var.project_name}-bastion" })
}

# ===== Output public IP =====
output "public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}
