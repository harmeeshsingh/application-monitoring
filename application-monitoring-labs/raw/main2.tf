provider "aws" {
  region = "us-east-1"  # Change this to your region
}

# KEY PAIR
# -----------------------------
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "apm"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "pem" {
  filename        = "apm.pem"
  content         = tls_private_key.key.private_key_pem
  file_permission = "0400"
}

resource "aws_instance" "apm_ec2" {
  ami                    = "ami-0cb91c7de36eed2cb"  # Change based on your region
  instance_type          = "t3.micro"
  key_name               = "apm"  # Ensure you have an SSH key pair in AWS
  iam_instance_profile   = aws_iam_instance_profile.apm_profile.name
  security_groups        = [aws_security_group.apm_sg.name]

  tags = {
    Name = "APM-EC2-Instance"
  }
}

resource "aws_security_group" "apm_sg" {
  name        = "apm-security-group"
  description = "Allow inbound access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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

resource "aws_iam_role" "apm_role" {
  name = "APMRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.apm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "apm_profile" {
  name = "APMInstanceProfile"
  role = aws_iam_role.apm_role.name
}

output "ec2_public_ip" {
  value = aws_instance.apm_ec2.public_ip
}