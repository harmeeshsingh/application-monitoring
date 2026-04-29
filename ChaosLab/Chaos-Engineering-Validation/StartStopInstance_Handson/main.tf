provider "aws" {
  region = "us-east-2"
}

# Security Group for EC2 + ALB
resource "aws_security_group" "demo_sg" {
  name        = "chaos-demo-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Instance A in us-east-2a
resource "aws_instance" "instance_a" {
  ami           = "ami-0cfde0ea8edd312d4"
  instance_type = "t2.micro"
  subnet_id     = element(data.aws_subnets.default.ids, 0)
  availability_zone = "us-east-2a"
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              echo "Hello from Instance A (us-east-2a)" > /var/www/html/index.html
              sudo systemctl start nginx
              sudo systemctl enable nginxd
              EOF
  tags = {
    Name = "Instance-A"
  }
}

# Instance B in us-east-2b
resource "aws_instance" "instance_b" {
  ami           = "ami-0cfde0ea8edd312d4"
  instance_type = "t2.micro"
  subnet_id     = element(data.aws_subnets.default.ids, 1)
  availability_zone = "us-east-2b"
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              echo "Hello from Instance B (us-east-2b)" > /var/www/html/index.html
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF
  tags = {
    Name = "Instance-B"
  }
}

# Create Load Balancer
resource "aws_lb" "app_lb" {
  name               = "chaos-demo-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demo_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "app_tg" {
  name     = "chaos-demo-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path = "/"
    port = "80"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Register instances in Target Group
resource "aws_lb_target_group_attachment" "a" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.instance_a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "b" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.instance_b.id
  port             = 80
}

# IAM Role for FIS
resource "aws_iam_role" "fis_role" {
  name = "ChaosFISRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "fis.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach Policy to FIS Role
resource "aws_iam_role_policy" "fis_policy" {
  name = "ChaosFISPolicy"
  role = aws_iam_role.fis_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "ec2:StopInstances",
        "ec2:StartInstances",
        "ec2:DescribeInstances"
      ]
      Resource = "*"
    }]
  })
}

# FIS Experiment to stop Instance A
resource "aws_fis_experiment_template" "chaos_experiment" {
  description = "Chaos Engineering Demo: Stop Instance A"
  role_arn    = aws_iam_role.fis_role.arn

  stop_condition {
    source = "none"
  }

  target {
    name   = "TargetInstances"
    resource_type = "aws:ec2:instance"
    selection_mode = "ALL"
    resource_arns = [aws_instance.instance_a.arn]
  }

  action {
    name = "stop-instances"
    action_id = "aws:ec2:stop-instances"

    target {
      key   = "Instances"
      value = "TargetInstances"
    }
  }

  tags = {
    Name = "ChaosExperiment"
  }
}

output "load_balancer_dns" {
  value = aws_lb.app_lb.dns_name
}

