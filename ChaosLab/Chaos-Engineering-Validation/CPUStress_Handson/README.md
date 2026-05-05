# AWS EC2 Anomaly Detection with Terraform

This project automates the deployment of an AWS infrastructure that monitors EC2 CPU utilization. It uses **CloudWatch Anomaly Detection** to identify unusual behavior and triggers an **SNS Email Notification** when performance deviates from the expected baseline.

## 🚀 Features
*   **Infrastructure as Code:** Fully automated using Terraform.
*   **Smart Monitoring:** Uses Machine Learning-based Anomaly Detection instead of just static thresholds.
*   **Auto-Alerting:** Integrated SNS Topic for real-time email alerts.
*   **Stress Testing:** Includes scripts to simulate high CPU load for validation.

## 📋 Prerequisites
*   [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.7.0+)
*   [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate IAM permissions.
*   An existing AWS Key Pair (.pem file) for SSH access.

## 🛠️ Deployment Steps

1. **Initialize Terraform:**
   ```bash
   terraform init