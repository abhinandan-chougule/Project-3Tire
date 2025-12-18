# ===== Get latest Amazon Linux 2 AMI =====
data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
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
  ami                         = data.aws_ami.amazon_linux2.id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  key_name                    = var.ec2_key_name

  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = merge(var.tags, { Name = "${var.project_name}-bastion" })
}

# ===== Output public IP =====
output "public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}
