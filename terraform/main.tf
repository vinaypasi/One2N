provider "aws" {
  region = "us-east-1"
}

# S3 Bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name
}

# IAM Role for EC2 Instance with S3 Permissions
resource "aws_iam_role" "ec2_role" {
  name               = "http_service_ec2_role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Effect : "Allow",
        Principal : {
          Service : "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy to Access S3 Bucket
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_access_policy"
  description = "Allow access to S3 bucket"
  policy      = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action   : ["s3:*"],
        Effect   : "Allow",
        Resource : [
          aws_s3_bucket.app_bucket.arn,
          "${aws_s3_bucket.app_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "http_service_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Security Group for EC2 Instance
resource "aws_security_group" "http_sg" {
  name        = "http_service_sg"
  description = "Allow HTTP and HTTPS inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "http_service" {
  ami           = "ami-012967cc5a8c9f891" # Amazon Linux 2023
  instance_type = "t2.micro"

  user_data = file("user-data.sh")

  security_groups = [aws_security_group.http_sg.name]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}
