# EC2 CPU Anomaly Detection with CloudWatch, SNS & Slack

Monitor EC2 CPU spikes using AWS CloudWatch Anomaly Detection, with alerts via Email and Slack.

---

## Architecture

```
EC2 (Ubuntu)
    ↓ CPU metrics
CloudWatch
    ↓ evaluated by
Two Alarms (Threshold + Anomaly Detection)
    ↓ triggers
SNS Topic
    ├── Email Subscription
    └── Lambda Function → Slack Webhook
```

---

## What This Does

| Component | Purpose |
|---|---|
| EC2 (t2.micro) | The monitored instance |
| CloudWatch Agent | Collects CPU metrics from EC2 |
| CPU_Threshold_Exceeded | Alerts when CPU > 75% for 2 consecutive minutes |
| CPU_Anomaly_Detection | Alerts when CPU deviates from normal ML pattern |
| SNS Topic | Routes alerts to Email and Lambda |
| Lambda Function | Formats and forwards alerts to Slack |

---

## Prerequisites

- AWS Account with IAM user (Access Key + Secret Key)
- Terraform >= 1.7.0
- AWS CLI configured
- Slack workspace with Incoming Webhook enabled

---

## Setup

### Option A — Terraform (Automated)

1. **Clone the repo**
```bash
git clone <your-repo-url>
cd ec2-anomaly-detection
```

2. **Update variables in main.tf**
```hcl
endpoint  = "your-email@example.com"   # SNS email
key_name  = "your-key-pair-name"       # EC2 key pair
```

3. **Deploy**
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

4. **Confirm SNS email subscription** — check your inbox and click the confirmation link.

---

### Option B — AWS Console (Manual)

#### Step 1 — Launch EC2
```
EC2 → Launch Instance
├── AMI: Ubuntu Server 24.04 LTS
├── Instance type: t2.micro
├── Key pair: your existing key pair
└── User Data:
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y stress
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i amazon-cloudwatch-agent.deb
    sudo systemctl enable amazon-cloudwatch-agent
```

#### Step 2 — Install CloudWatch Agent (if not auto-installed)
```bash
ssh -i your-key.pem ubuntu@<EC2-Public-IP>
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb
```

Create config and start agent:
```bash
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<'EOF'
{
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
```

#### Step 3 — Create SNS Topic
```
SNS → Topics → Create Topic
├── Type: Standard
├── Name: cpu-anomaly-alerts
└── Create Subscription → Protocol: Email → your email
```
Confirm the subscription via email.

#### Step 4 — Create CloudWatch Alarms

**Alarm 1 — Threshold:**
```
CloudWatch → Alarms → Create Alarm
├── Metric: EC2 → CPUUtilization → your instance
├── Period: 1 minute
├── Threshold type: Static
├── Condition: Greater than 75
├── Datapoints: 2 out of 2
├── Notification: cpu-anomaly-alerts
└── Name: CPU_Threshold_Exceeded
```

**Alarm 2 — Anomaly Detection:**
```
CloudWatch → Alarms → Create Alarm
├── Metric: EC2 → CPUUtilization → your instance
├── Period: 1 minute
├── Threshold type: Anomaly detection
├── Condition: Greater than upper band
├── Anomaly threshold: 2
├── Datapoints: 2 out of 2
├── Notification: cpu-anomaly-alerts
└── Name: CPU_Anomaly_Detection
```

#### Step 5 — Connect Slack

1. Go to [api.slack.com/apps](https://api.slack.com/apps)
2. Create New App → Incoming Webhooks → Add to Workspace
3. Copy the Webhook URL

Create Lambda function:
```
Lambda → Create Function
├── Name: sns-to-slack
└── Runtime: Python 3.12
```

Paste this code:
```python
import json
import urllib.request

SLACK_WEBHOOK_URL = "YOUR_WEBHOOK_URL_HERE"

def lambda_handler(event, context):
    message = event['Records'][0]['Sns']['Message']
    subject = event['Records'][0]['Sns']['Subject']

    slack_message = {
        "text": f"*🚨 AWS Alert: {subject}*\n{message}"
    }

    data = json.dumps(slack_message).encode("utf-8")
    req = urllib.request.Request(SLACK_WEBHOOK_URL, data=data)
    urllib.request.urlopen(req)

    return {"statusCode": 200}
```

Add SNS trigger:
```
Lambda → your function → Add Trigger
├── Source: SNS
└── Topic: cpu-anomaly-alerts
```

---

## Simulate CPU Spike

SSH into EC2 and run:
```bash
sudo stress --cpu $(nproc) --timeout 300
```

This fully loads all CPU cores for 5 minutes. Watch CloudWatch alarms turn red and check your Email + Slack for alerts.

---

## Cleanup

**Terraform:**
```bash
terraform destroy -auto-approve
```

**Console — delete in this order:**
```
1. EC2 Instance
2. CloudWatch Alarms
3. Lambda Function
4. SNS Topic + Subscriptions
```

---

## Key Concepts Learned

| Concept | Description |
|---|---|
| Anomaly Detection | ML-based alerting without fixed thresholds |
| Evaluation Periods | Reduces noise by requiring sustained spikes |
| SNS | Decouples alarm from notification channel |
| Lambda as middleware | Formats SNS messages for Slack |
| CloudWatch Agent | Extends metrics beyond default EC2 monitoring |

---

## Production Improvements

- Attach `CloudWatchAgentServerPolicy` IAM role to EC2
- Add memory and disk metrics via CloudWatch Agent
- Add `Insufficient Data` alarm state notification
- Replace Lambda with PagerDuty for on-call routing
- Create CloudWatch Dashboard for visual monitoring
- Use Terraform remote state (S3 backend) for team collaboration