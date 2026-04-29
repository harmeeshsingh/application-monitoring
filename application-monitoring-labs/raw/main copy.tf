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

              mkdir -p /home/ubuntu/app
              cd /home/ubuntu/app
              
              npm init -y
              npm install express morgan

              cat <<APP > app.js
              const express = require('express');
              const morgan = require('morgan');
              const app = express();

              // Structured logging to help monitoring tools parse logs
              app.use(morgan(':method :url :status :res[content-length] - :response-time ms'));

              // 1. Standard Request: Variable latency
              app.get('/request', (req, res) => {
                const latency = Math.floor(Math.random() * 500);
                setTimeout(() => {
                  res.json({ message: 'Request processed', latency: latency + 'ms' });
                }, latency);
              });

              // 2. Payment API: Simulates 4xx and 5xx errors + High Latency
              app.get('/payment', (req, res) => {
                const random = Math.random();
                const delay = random > 0.8 ? 3000 : 200; // Occasional major spike

                setTimeout(() => {
                  if (random > 0.9) {
                    res.status(500).json({ error: 'Database Connection Timeout', code: 'ERR_500' });
                  } else if (random > 0.7) {
                    res.status(402).json({ error: 'Incomplete Payment', code: 'ERR_402' });
                  } else {
                    res.status(200).json({ status: 'success', transactionId: Math.random().toString(36).substring(7) });
                  }
                }, delay);
              });

              // 3. Memory Leak Simulator: Useful for infrastructure monitoring
              let leak = [];
              app.get('/leak', (req, res) => {
                for (let i = 0; i < 10000; i++) {
                  leak.push({ data: Math.random() });
                }
                res.send('Memory usage increased');
              });

              // 4. Health Check
              app.get('/', (req, res) => {
                res.send('Observability Test App is Online');
              });

              app.listen(3000, () => {
                console.log('--- Monitoring Test App Started on Port 3000 ---');
              });
              APP

              chown -R ubuntu:ubuntu /home/ubuntu/app
              nohup node app.js > app.log 2>&1 &
              EOF

  tags = {
    Name = "monitor-test"
  }
}

lifecycle {
    ignore_changes = [user_data]
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