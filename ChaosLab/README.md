# ChaosLab

This folder contains hands-on Chaos Engineering experiments designed to validate the **resilience and observability** of AWS infrastructure.

## What is Chaos Engineering?

Chaos Engineering is the practice of intentionally injecting failures into a system to uncover weaknesses before they cause real outages. These labs help answer:

> *"Does our system recover gracefully when something goes wrong?"*

## Structure

```
ChaosLab/
└── Chaos-Engineering-Validation/
    ├── CPUStress_Handson/        # Simulate CPU spikes + CloudWatch anomaly detection
    └── StartStopInstance_Handson/  # Simulate AZ failure using AWS FIS
```

## Experiments

| Lab | What it tests | Tools used |
|-----|--------------|------------|
| CPUStress_Handson | CPU spike detection & alerting | EC2, CloudWatch, SNS, Terraform |
| StartStopInstance_Handson | AZ failure & traffic failover | EC2, ALB, AWS FIS, Terraform |

## Prerequisites

- Terraform v1.7.0+
- AWS CLI configured with IAM permissions
- AWS Key Pair for SSH access

## How to use

Each sub-folder is self-contained. Navigate into the experiment you want to run and follow its `README.md`.

```bash
cd Chaos-Engineering-Validation/CPUStress_Handson
terraform init && terraform apply
```
