provider "aws" {
  region = "us-east-1"
}

# ─────────────────────────────────────────
# Data Sources - Auto fetch VPC and Subnet
# ─────────────────────────────────────────
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ─────────────────────────────────────────
# IAM Role for SSM
# ─────────────────────────────────────────
resource "aws_iam_role" "ssm_role" {
  name = "EC2-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "EC2-SSM-Role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "EC2-SSM-Profile"
  role = aws_iam_role.ssm_role.name
}

# ─────────────────────────────────────────
# Security Group - No Inbound Rules
# ─────────────────────────────────────────
resource "aws_security_group" "ssm_sg" {
  name        = "SSM-Private-EC2-SG"
  description = "Security group for SSM private EC2 - no inbound required"
  vpc_id      = data.aws_vpc.default.id

  # No inbound rules needed for SSM

  egress {
    description = "Allow HTTPS outbound for SSM"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSM-Private-EC2-SG"
  }
}

# ─────────────────────────────────────────
# EC2 Instance - No Public IP, No PEM
# ─────────────────────────────────────────
resource "aws_instance" "private_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnets.private.ids[0]
  vpc_security_group_ids      = [aws_security_group.ssm_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = false   # ← No public IP
  # No key_name                         # ← No PEM key

  tags = {
    Name        = "private-ssm-ec2"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.private_ec2.id
}

output "instance_private_ip" {
  description = "Private IP of EC2"
  value       = aws_instance.private_ec2.private_ip
}

output "ssm_login_command" {
  description = "Command to login via SSM"
  value       = "aws ssm start-session --target ${aws_instance.private_ec2.id} --region us-east-1"
}
