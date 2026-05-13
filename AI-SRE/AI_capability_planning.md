# AI SRE Capacity Planning using AWS + Terraform + Lambda

## Overview

This project demonstrates an AI-powered SRE Capacity Planning system built using AWS services, Terraform, and Amazon Bedrock.

The system:

- Collects real EC2 CPU metrics from CloudWatch
- Uses Amazon Bedrock Nova Lite for AI-driven analysis
- Generates EC2 scaling recommendations
- Sends AI-generated reports through SNS email notifications
- Provisions the entire infrastructure using Terraform

---

# Architecture

## Workflow

```text
EC2 → CloudWatch Metrics → Lambda → Amazon Bedrock → SNS → Email
```

### Trigger Mode

Current implementation uses:

```text
Manual Lambda Trigger (Demo Mode)
```

The Lambda function is manually executed from the AWS Console during testing and demonstrations.

## Components

| Component | Purpose |
|---|---|
| EC2 Instance | Generates real CPU metrics |
| CloudWatch | Stores EC2 CPU utilization metrics |
| Lambda Function | Collects metrics and invokes AI analysis |
| Amazon Bedrock | Generates AI-based capacity planning insights |
| SNS | Sends email notifications |
| Terraform | Automates infrastructure provisioning |

---

# Project Structure

```text
ai-capacity-planning/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── lambda_capacity.py
├── package/
├── lambda.zip
└── README.md
```

### Project Files

| File | Purpose |
|---|---|
| `main.tf` | Terraform infrastructure definition |
| `lambda_capacity.py` | Core AI capacity planning logic |
| `lambda.zip` | Lambda deployment package |
| `package/` | Optional dependency folder |
| `README.md` | Project documentation |

---

# Prerequisites

Before starting, ensure the following tools are installed:

- Terraform >= 1.5
- AWS CLI configured
- Python 3.12
- zip utility
- AWS account with Bedrock access enabled

---

# Terraform Infrastructure

The infrastructure provisions:

- Ubuntu EC2 instance
- IAM roles and policies
- Lambda function
- SNS topic and email subscription
- Security group
- SSH key pair

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

############################
# VARIABLES
############################

variable "aws_region" {
  default = "us-east-1"
}

variable "email_address" {
  description = "Email address for SNS notifications"
  type        = string
}

############################
# KEY PAIR
############################

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "ec2-key.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "generated" {
  key_name   = "capacity-key"
  public_key = tls_private_key.key.public_key_openssh
}

############################
# SECURITY GROUP
############################

resource "aws_security_group" "ec2_sg" {
  name        = "capacity-sg"
  description = "Allow SSH access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "capacity-security-group"
  }
}

############################
# IAM ROLE FOR EC2
############################

resource "aws_iam_role" "ec2_role" {
  name = "capacity-ec2-role"

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
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "capacity-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

############################
# UBUNTU AMI
############################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

############################
# EC2 INSTANCE
############################

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "capacity-planner-ec2"
  }
}

############################
# SNS TOPIC
############################

resource "aws_sns_topic" "email_topic" {
  name = "capacity-ai-email"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.email_topic.arn
  protocol  = "email"
  endpoint  = var.email_address
}

############################
# LAMBDA IAM ROLE
############################

resource "aws_iam_role" "lambda_role" {
  name = "capacity-lambda-role"

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
  name = "capacity-lambda-policy"
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
          "cloudwatch:GetMetricStatistics"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "*"
      }
    ]
  })
}

############################
# LAMBDA FUNCTION
############################

resource "aws_lambda_function" "capacity" {
  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  function_name = "capacity-ai"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_capacity.lambda_handler"
  runtime       = "python3.12"
  timeout       = 60

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.email_topic.arn
      INSTANCE_ID   = aws_instance.ec2.id
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy
  ]
}

############################
# OUTPUTS
############################

output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}

output "lambda_function_name" {
  value = aws_lambda_function.capacity.function_name
}
```

---

# Lambda Function

## Create `lambda_capacity.py`

```python
import boto3
import json
import os
from datetime import datetime, timedelta

sns = boto3.client("sns")
cw = boto3.client("cloudwatch")
bedrock = boto3.client("bedrock-runtime")

INSTANCE_ID = os.environ["INSTANCE_ID"]
TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def get_cpu_metrics():
    end = datetime.utcnow()
    start = end - timedelta(hours=3)

    metrics = cw.get_metric_statistics(
        Namespace="AWS/EC2",
        MetricName="CPUUtilization",
        Dimensions=[
            {
                "Name": "InstanceId",
                "Value": INSTANCE_ID
            }
        ],
        StartTime=start,
        EndTime=end,
        Period=300,
        Statistics=["Average"]
    )

    datapoints = sorted(
        metrics["Datapoints"],
        key=lambda x: x["Timestamp"]
    )

    cpu_values = [round(point["Average"], 2) for point in datapoints]

    if not cpu_values:
        return "No CPU metrics available"

    return ", ".join(map(str, cpu_values))


def call_bedrock(cpu_data):
    prompt = f"""
You are an SRE doing EC2 capacity planning.

IMPORTANT RULES:
- Use ONLY the CPU metrics provided below.
- DO NOT make assumptions.
- DO NOT mention Kubernetes, containers, pods, HPA, or autoscaling groups.
- This system uses a SINGLE EC2 instance.
- Give recommendations ONLY for EC2 instance sizing or scaling.
- If data is limited, say 'Data is limited but based on available metrics'.

CPU Utilization datapoints (%):
{cpu_data}

Provide output in this EXACT format:

EC2 Capacity Report

1. Observed CPU Pattern
2. Current Risk Level (Low/Medium/High)
3. 24h Capacity Prediction
4. EC2 Recommendation (scale up / keep same / scale down)
5. Suggested Instance Type Change (if needed)
"""

    body = {
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "text": prompt
                    }
                ]
            }
        ]
    }

    response = bedrock.invoke_model(
        modelId="amazon.nova-lite-v1:0",
        body=json.dumps(body)
    )

    result = json.loads(response["body"].read())

    return result["output"]["message"]["content"][0]["text"]


def lambda_handler(event, context):
    cpu_data = get_cpu_metrics()

    report = call_bedrock(cpu_data)

    sns.publish(
        TopicArn=TOPIC_ARN,
        Subject="AI Capacity Planning Report",
        Message=report
    )

    return {
        "status": "success",
        "report": report
    }
```

---

# Package Lambda Dependencies

The improved implementation does not require external Python libraries.

The original version used the `requests` library packaging workflow.

## Original Packaging Commands

```bash
mkdir package
pip3 install requests -t package/

cd package
zip -r ../lambda.zip .
cd ..
zip -g lambda.zip lambda_capacity.py
```

## Optimized Packaging

Since the current implementation uses only `boto3` (already available inside AWS Lambda runtime), external dependency packaging is unnecessary.

Use:

```bash
zip lambda.zip lambda_capacity.py
```

Create the Lambda deployment package:

```bash
zip lambda.zip lambda_capacity.py
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
terraform plan -var="email_address=your-email@example.com"
```

## Step 4 — Apply

```bash
terraform apply -var="email_address=your-email@example.com"
```

Type:

```text
yes
```

when prompted.

---

# Confirm SNS Subscription

AWS SNS will send a confirmation email.

Open your email inbox and click:

```text
Confirm subscription
```

Without this step, notifications will not work.

---

# Generate CPU Load

SSH into the EC2 instance:

```bash
ssh -i ec2-key.pem ubuntu@<EC2_PUBLIC_IP>
```

Install stress utility:

```bash
sudo apt update
sudo apt install stress -y
```

Generate CPU spikes:

```bash
stress --cpu 2 --timeout 300
```

This creates real CPU utilization data inside CloudWatch.

---

# Test Lambda Function

## Using AWS Console

1. Open AWS Lambda Console
2. Select function:

```text
capacity-ai
```

3. Click:

```text
Test
```

4. Use test payload:

```json
{}
```

5. Execute the function.

---

# Internal Workflow During Execution

## What Happens After CPU Spike?

After generating CPU load using the `stress` utility:

```text
CloudWatch metrics increase
        ↓
Lambda reads CPU spikes
        ↓
Amazon Bedrock analyzes usage pattern
        ↓
AI generates scaling recommendation
        ↓
SNS sends email report
```

This simulates a real-world SRE capacity planning workflow.

---

# Internal Workflow During Execution

The Lambda function performs the following steps:

1. Reads EC2 CPU metrics from CloudWatch
2. Sends metrics to Amazon Bedrock
3. AI generates capacity recommendations
4. SNS sends the AI report to email
5. User receives the report automatically

---

# Example AI Recommendation

The AI model used in this project:

```text
amazon.nova-lite-v1:0
```

The Lambda function sends prompts similar to:

```text
Here is real EC2 CPU usage data: [64,0,41,99]
Provide EC2 capacity planning recommendation.
No assumptions.
No Kubernetes.
Only EC2 scaling advice.
```

The AI then generates structured infrastructure recommendations.

---

# Example AI Recommendation

```text
EC2 Capacity Report

1. Observed CPU Pattern
CPU usage shows multiple spikes above 80%.

2. Current Risk Level
Medium

3. 24h Capacity Prediction
Sustained load increase may cause performance degradation.

4. EC2 Recommendation
Scale up the EC2 instance.

5. Suggested Instance Type Change
Move from t2.micro to t3.small.
```

---

# Security Improvements Applied

The original implementation was improved with:

- Better IAM policy scoping
- Removed unnecessary `requests` dependency
- Added Terraform outputs
- Added source code hashing for Lambda updates
- Fixed undefined variable bug in Lambda
- Added tagging for AWS resources
- Improved metric sorting logic
- Improved Terraform compatibility
- Added validation workflow

---

# Future Enhancements

Possible production-grade enhancements:

- CloudWatch dashboard integration
- Scheduled EventBridge triggers
- Auto-remediation workflows
- Multi-instance analysis
- Historical trend analysis
- Slack or Microsoft Teams notifications
- DynamoDB report storage
- Auto-scaling recommendations
- AI-powered anomaly detection

---

# Cleanup Resources

To destroy the infrastructure:

```bash
terraform destroy -var="email_address=your-email@example.com"
```

---

# Final Summary

You now have a working AI-powered SRE Capacity Planner.

## Features

- Collects real EC2 CPU metrics
- Performs AI-based capacity analysis
- Generates scaling recommendations
- Sends automated email reports
- Fully automated infrastructure using Terraform
- Uses Amazon Bedrock Nova Lite
- Demonstrates practical AI + DevOps integration

---

# Author

Built for learning and demonstrating:

- AWS Infrastructure Automation
- Terraform
- Serverless Architecture
- AI-driven Operations
- SRE Capacity Planning
- Amazon Bedrock Integration
