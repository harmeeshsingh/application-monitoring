# Chaos Experiment: Instance Start/Stop (AZ Failure Simulation)

## Objective

Validate infrastructure resiliency against an **Availability Zone (AZ) failure** using AWS Fault Injection Simulator (FIS).

- Deploy two EC2 instances in separate AZs
- Place an ALB in front of them
- Stop one instance via FIS
- Observe traffic automatically shift to the healthy instance

---

## Architecture

```
        ┌──────────────────────┐
        │   Application LB     │
        │  (DNS entry point)   │
        └─────────┬────────────┘
                  │
    ┌─────────────┴─────────────┐
    │                           │
┌───▼──────────────┐   ┌───────▼──────────┐
│  Instance A       │   │  Instance B       │
│  us-east-2a       │   │  us-east-2b       │
│  "Hello from A"   │   │  "Hello from B"   │
└───────────────────┘   └──────────────────┘
```

**Terraform provisions:**
- Default VPC + subnets across AZs
- Security Group (SSH port 22, HTTP port 80)
- 2x EC2 instances (t2.micro, Ubuntu, nginx)
- Application Load Balancer with health checks
- IAM Role + Policy for FIS
- FIS Experiment Template (stops Instance A)

---

## Prerequisites

- Terraform v1.7.0+
- AWS CLI configured with IAM permissions
- AWS Key Pair for SSH access

---

## Deployment

```bash
terraform init
terraform apply
```

Note the `load_balancer_dns` output — this is your test URL.

---

## Running the Chaos Experiment

1. Open the ALB URL in your browser → you'll see **Instance A or B** serving traffic
2. Go to **AWS Console → Fault Injection Simulator → Experiment Templates**
3. Find `ChaosExperiment` → click **Start Experiment**
4. Refresh the browser → ALB shifts traffic to the surviving instance
5. After FIS completes, both instances return to healthy state

---

## Expected Outcome

| State | Result |
|-------|--------|
| Normal | ALB routes to both instances |
| Instance A stopped (FIS) | ALB routes 100% to Instance B |
| FIS complete | System returns to normal |

---

## Key Takeaway

> Chaos Engineering is not about breaking things — it's about building **confidence** that the system recovers gracefully.
