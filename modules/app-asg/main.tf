# IAM role to read S3 artifacts
resource "aws_iam_role" "app_role" {
  name               = "${var.project_name}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect   = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Policy for S3 access
resource "aws_iam_role_policy" "s3_access" {
  name = "${var.project_name}-s3-access"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::${var.artifact_bucket_name}",
          "arn:aws:s3:::${var.artifact_bucket_name}/*"
        ]
      }
    ]
  })
}

# Attach SSM core policy as well (so you can connect via Session Manager)
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.project_name}-app-profile"
  role = aws_iam_role.app_role.name
}

# Launch template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = var.app_ami_id
  instance_type = var.instance_type
  key_name      = var.ec2_key_name

  vpc_security_group_ids = [var.app_security_group_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.app_profile.name
  }

  user_data = base64encode(<<-EOT
#!/bin/bash
set -eux

# ===== Update system and install dependencies =====
sudo yum update -y
sudo yum install -y java-11-amazon-corretto git unzip

# ===== Install AWS CLI v2 =====
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# ===== Fetch the Spring Boot JAR from S3 =====
aws s3 cp "s3://${var.artifact_bucket_name}/${var.artifact_object_key}" /home/ec2-user/app.jar
sudo chown ec2-user:ec2-user /home/ec2-user/app.jar

# ===== Create a systemd service =====
sudo bash -c 'cat > /etc/systemd/system/petclinic.service <<EOF
[Unit]
Description=PetClinic Spring Boot App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user
Environment=SPRING_PROFILES_ACTIVE=mysql
Environment=SPRING_DATASOURCE_URL=jdbc:mysql://${var.db_host}:${var.db_port}/${var.db_name}?useSSL=false&allowPublicKeyRetrieval=true
Environment=SPRING_DATASOURCE_USERNAME=${var.db_username}
Environment=SPRING_DATASOURCE_PASSWORD=${var.db_password}
ExecStart=/usr/bin/java -jar /home/ec2-user/app.jar
SuccessExitStatus=143
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable petclinic
sudo systemctl start petclinic
EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.project_name}-app" })
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                      = "${var.project_name}-asg"
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 60

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }
}
