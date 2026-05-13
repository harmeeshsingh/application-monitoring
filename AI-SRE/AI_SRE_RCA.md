# AI-Powered Incident Response & Root Cause Analysis (RCA)

## Overview

This project demonstrates a fully automated AI-driven SRE Incident Response pipeline using:

- AWS EC2
- CloudWatch Alarms
- AWS Lambda
- Amazon Bedrock Nova Lite
- SNS Notifications
- Terraform Infrastructure as Code

The system automatically:

1. Detects high CPU utilization on EC2
2. Triggers a CloudWatch alarm
3. Invokes a Lambda function automatically
4. Sends incident context to Amazon Bedrock
5. Generates an AI-powered RCA report
6. Emails the incident report instantly to the on-call engineer

This simulates a real-world AI-assisted SRE incident response workflow.

---

# Architecture

## Workflow

```text
EC2 → CloudWatch Alarm → SNS → Lambda → Amazon Bedrock → SNS Email → On-call Engineer
```

## Detailed Flow

```text
EC2 (CPU spike generator)
        ↓
CloudWatch Alarm (High CPU)
        ↓
SNS Topic (Alarm trigger)
        ↓
Lambda (AI RCA Engine)
        ↓
Amazon Bedrock (Nova Lite)
        ↓
SNS Email Topic
        ↓
AI Incident Report Email
```

---

# Features

## Automated Incident Response

- Real-time CPU monitoring
- Automatic CloudWatch alarm triggering
- AI-generated Root Cause Analysis
- Automated remediation recommendations
- Email notifications to operations teams

## Infrastructure as Code

Terraform provisions:

- EC2 instance
- IAM roles and policies
- Lambda function
- CloudWatch alarms
- SNS topics and subscriptions
- SSH key pair
- Security groups

---

# Project Structure

```text
ai-incident-response/
│
├── main.tf
├── lambda_function.py
├── lambda.zip
└── README.md
```

---

# Prerequisites

Ensure the following tools are installed:

- Terraform >= 1.5
- AWS CLI configured
- Python 3.12
- zip utility
- AWS account with Amazon Bedrock access enabled

---

# What Terraform Builds Automatically

## IAM + Security

Terraform provisions IAM permissions for:

- CloudWatch Logs
- SNS Publish
- Bedrock Model Invocation

---

## EC2 Incident Generator

Creates an EC2 instance used to:

- Generate CPU spikes
- Simulate production incidents
- Test monitoring workflows

Ports opened:

| Port | Purpose |
|---|---|
| 22 | SSH Access |
| 80 | Web/Application Access |

---

## Monitoring

Terraform creates:

| Resource | Value |
|---|---|
| Alarm Name | HighCPU-AI-SRE |
| Metric | CPUUtilization |
| Threshold | > 70% |
| Evaluation Window | 2 Minutes |

This simulates a real production monitoring alert.

---

## SNS Topics

### Alarm Trigger Topic

Used internally:

```text
CloudWatch → Lambda
```

### Email Notification Topic

Used for:

```text
Lambda → Engineer Email
```

Terraform automatically subscribes your email address.

---

## Lambda Function

Terraform deploys:

| Property | Value |
|---|---|
| Function Name | ai-rca-engine |
| Runtime | Python 3.12 |
| Trigger | SNS |

The Lambda function executes automatically whenever the CloudWatch alarm fires.

---

# Terraform Configuration

## Create `main.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.44"
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
  region = var.aws_region
}

################################################
# VARIABLES
################################################

variable "aws_region" {
  default = "us-east-1"
}

variable "alert_email" {
  description = "Email address for incident alerts"
  type        = string
}

################################################
# SSH KEY
################################################

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  filename        = "ai-sre-key.pem"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "generated" {
  key_name   = "ai-sre-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

################################################
# SECURITY GROUP
################################################

resource "aws_security_group" "demo_sg" {
  name        = "ai-sre-demo-sg"
  description = "Security group for AI SRE demo"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

  tags = {
    Name = "ai-sre-security-group"
  }
}

################################################
# UBUNTU AMI
################################################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

################################################
# EC2 INCIDENT GENERATOR
################################################

resource "aws_instance" "demo" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated.key_name
  vpc_security_group_ids      = [aws_security_group.demo_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "AI-SRE-Demo"
  }
}

################################################
# SNS TOPICS
################################################

resource "aws_sns_topic" "alarm_topic" {
  name = "ai-sre-alarm-topic"
}

resource "aws_sns_topic" "email_topic" {
  name = "ai-sre-email-topic"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.email_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

################################################
# CLOUDWATCH CPU ALARM
################################################

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPU-AI-SRE"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "AI SRE high CPU incident alarm"

  dimensions = {
    InstanceId = aws_instance.demo.id
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]

  tags = {
    Name = "AI-SRE-CPU-Alarm"
  }
}

################################################
# LAMBDA IAM ROLE
################################################

resource "aws_iam_role" "lambda_role" {
  name = "ai-sre-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "ai-sre-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.email_topic.arn
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "*"
      }
    ]
  })
}

################################################
# LAMBDA FUNCTION
################################################

resource "aws_lambda_function" "ai_rca" {
  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  function_name = "ai-rca-engine"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 60

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.email_topic.arn
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy
  ]
}

################################################
# ALLOW SNS TO INVOKE LAMBDA
################################################

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ai_rca.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm_topic.arn
}

################################################
# SNS SUBSCRIPTION TO LAMBDA
################################################

resource "aws_sns_topic_subscription" "lambda_sub" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.ai_rca.arn
}

################################################
# OUTPUTS
################################################

output "ec2_public_ip" {
  value = aws_instance.demo.public_ip
}

output "lambda_function_name" {
  value = aws_lambda_function.ai_rca.function_name
}
```

---

# Lambda Function

## Create `lambda_function.py`

```python
import json
import boto3
import os

sns = boto3.client("sns")
bedrock = boto3.client("bedrock-runtime")

MODEL_ID = "amazon.nova-lite-v1:0"


def generate_ai_rca(alarm_name="HighCPU-AI-SRE"):

    prompt = f"""
CloudWatch Alarm Triggered: {alarm_name}

Create a professional SRE Incident Report with:

1. Incident Summary
2. Root Cause
3. Customer Impact
4. Immediate Fix
5. Prevention Steps

The report should be concise, operational, and production-focused.
"""

    response = bedrock.converse(
        modelId=MODEL_ID,
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "text": prompt
                    }
                ]
            }
        ],
        inferenceConfig={
            "maxTokens": 400,
            "temperature": 0.3
        }
    )

    return response["output"]["message"]["content"][0]["text"]


def lambda_handler(event, context):
    print("Generating AI RCA report...")

    try:
        alarm_name = "HighCPU-AI-SRE"

        if "Records" in event:
            sns_message = json.loads(event["Records"][0]["Sns"]["Message"])
            alarm_name = sns_message.get("AlarmName", alarm_name)

        report = generate_ai_rca(alarm_name)

        sns.publish(
            TopicArn=os.environ["SNS_TOPIC_ARN"],
            Subject="AI SRE Incident Report",
            Message=report
        )

        return {
            "status": "SUCCESS",
            "report": report
        }

    except Exception as error:
        print(f"Error: {str(error)}")

        return {
            "status": "FAILED",
            "error": str(error)
        }
```

---

# Package Lambda Function

Create the deployment package:

```bash
zip lambda.zip lambda_function.py
```

---

# Deploy Infrastructure

## Step 1 — Initialize Terraform

```bash
terraform init
```

## Step 2 — Validate

```bash
terraform validate
```

## Step 3 — Plan

```bash
terraform plan -var="alert_email=your-email@example.com"
```

## Step 4 — Apply

```bash
terraform apply -var="alert_email=your-email@example.com"
```

Type:

```text
yes
```

when prompted.

---

# Confirm SNS Subscription

AWS SNS will send a confirmation email.

Open the email and click:

```text
Confirm subscription
```

Without confirmation, email notifications will not work.

---

# Testing the Incident Pipeline

## Test 1 — Manual Lambda Test

### Open Lambda Console

1. Go to AWS Console
2. Search for:

```text
Lambda
```

3. Open function:

```text
ai-rca-engine
```

---

### Create Test Event

Use:

```json
{
  "source": "manual-test",
  "alarm": "HighCPU-AI-SRE"
}
```

This validates:

- Bedrock AI invocation
- Lambda execution
- SNS email delivery

---

## Test 2 — Real Incident Simulation

SSH into EC2:

```bash
ssh -i ai-sre-key.pem ubuntu@<EC2_PUBLIC_IP>
```

Install stress utility:

```bash
sudo apt update
sudo apt install stress -y
```

Generate CPU spike:

```bash
stress --cpu 2 --timeout 300
```

---

# Demo Flow

```text
Alarm → Lambda → Bedrock → Email → AI RCA Report
```

---

# Internal Workflow

## What Happens During an Incident?

```text
EC2 CPU spikes
        ↓
CloudWatch alarm triggers
        ↓
SNS invokes Lambda
        ↓
Lambda calls Amazon Bedrock
        ↓
AI generates RCA report
        ↓
SNS sends incident email
```

This simulates a real AI-assisted SRE response system.

---

# Example AI Incident Report

## Subject

```text
AI SRE Incident Report
```

## Example Email Body

```text
Incident Summary:
High CPU utilization detected on EC2 instance.

Root Cause:
Likely traffic spike or runaway process.

Customer Impact:
Application response latency increased.

Immediate Fix:
Restart affected services or scale the instance.

Prevention Steps:
Enable auto scaling and proactive monitoring.
```

---

# Security & Reliability Improvements Applied

The original implementation was enhanced with:

- Dynamic Ubuntu AMI lookup
- Better IAM policy structure
- Improved Lambda error handling
- Source code hashing for deployments
- Added Terraform validation workflow
- Improved alarm configuration
- Added resource tagging
- Added HTTP ingress rule consistency
- Added production-safe logging flow

---

# Future Enhancements

Potential production improvements:

- EventBridge scheduling
- Slack or Microsoft Teams alerts
- Auto-remediation workflows
- Multi-instance RCA analysis
- Historical incident tracking
- DynamoDB incident storage
- AI anomaly detection
- Grafana dashboards
- Auto-scaling integration

---

# Cleanup Resources

Destroy all infrastructure:

```bash
terraform destroy -var="alert_email=your-email@example.com"
```

---

# Final Summary

This project demonstrates a fully automated AI-powered SRE incident response platform.

## Capabilities

- Detects infrastructure incidents automatically
- Uses AI for Root Cause Analysis
- Generates remediation guidance
- Sends automated incident reports
- Uses Infrastructure as Code
- Demonstrates event-driven automation
- Integrates Amazon Bedrock AI into SRE workflows

---

# Author

Built for learning and demonstrating:

- AI for SRE
- AWS Automation
- Terraform
- Incident Response Engineering
- Cloud Monitoring
- Event-Driven Systems
- Amazon Bedrock Integration

