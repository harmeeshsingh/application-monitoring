terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "aws" {
  region = "us-east-1"  #Change accordingly
}

# -----------------------------
# VARIABLES
# -----------------------------
# variable "dynatrace_url" {}
# variable "dynatrace_token" {}

# -----------------------------
# KEY PAIR
# -----------------------------
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "auto-key1"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "pem" {
  filename        = "auto-key1.pem"
  content         = tls_private_key.key.private_key_pem
  file_permission = "0400"
}

# -----------------------------
# SECURITY GROUP
# -----------------------------
resource "aws_security_group" "sg" {
  name = "observability-sg"

  ingress {
    from_port   = 22
    to_port     = 22
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

# -----------------------------
# EC2 INSTANCE
# -----------------------------
resource "aws_instance" "obs" {
  ami           = "ami-04680790a315cd58d"   #change accordingly
  instance_type = "t3.micro"

  key_name = aws_key_pair.generated.key_name

  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
              sudo apt install -y nodejs


              # --------------------
              # Create Realistic App
              # --------------------
              
              mkdir -p /home/ubuntu/app
              cd /home/ubuntu/app
              chown -R ubuntu:ubuntu /home/ubuntu/app
              #curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
              #sudo apt install -y nodejs
              
              
              cat <<APP > app.js
              const express = require('express');
              const app = express();

              // Simulate request processing
              app.get('/request', (req, res) => {
                setTimeout(() => {
                  res.send('Request processed');
                }, Math.random() * 1000);
              });

              // Simulate payment API with failures
              app.get('/payment', (req, res) => {
                const delay = Math.random() * 2000;

                setTimeout(() => {
                  if (delay > 1500) {
                    res.status(500).send('Payment failed');
                  } else {
                    res.send('Payment success');
                  }
                }, delay);
              });

              // Health endpoint
              app.get('/', (req, res) => {
                res.send('Service is running');
              });

              app.listen(3000, () => console.log('App running'));
              APP

              npm init -y
              npm install
              npm install express

              nohup node app.js > app.log 2>&1 &
              EOF

  tags = {
    Name = "monitor-test"
  }
}

# -----------------------------
# OUTPUTS
# -----------------------------
output "public_ip" {
  value = aws_instance.obs.public_ip
}

output "app_url" {
  value = "http://${aws_instance.obs.public_ip}:3000"
}

output "ssh_command" {
  value = "ssh -i auto-key.pem ubuntu@${aws_instance.obs.public_ip}"
}