# application-monitoring-labs

Hands-on SRE labs covering application monitoring, observability, self-healing systems, and incident management. Each folder serves a specific purpose — see below.

## Structure

```
application-monitoring-labs/
├── commands/       # CLI commands, setup scripts, and K8s manifests used across labs
├── main files/     # Core lab documentation and reference material for each topic
└── raw/            # Working/draft infrastructure files (Terraform, configs, scripts)
```

## Lab Topics Covered

| Topic | Location |
|-------|----------|
| Application Performance Monitoring (APM) | `main files/` |
| Auto-scaling & Self-Healing Infrastructure | `main files/` + `commands/` |
| Dynatrace Observability | `main files/` |
| EKS Self-Healing & Toil Reduction | `main files/` + `commands/` |
| Incident Automation Lifecycle | `main files/` |
| Log Correlation & Debugging (ELK Stack) | `main files/` |
| Observability for Microservices | `main files/` |
| Security Incident Simulation | `main files/` |
| Active-Passive Fault Tolerance | `main files/` |
| EC2 CloudWatch Monitoring | `main files/` |

## Prerequisites

- AWS CLI configured
- Terraform v1.7.0+
- kubectl + EKS access
- Docker (for local stacks)

## How to Use

Start with a topic in `main files/` to understand the concept, then use the corresponding scripts/commands in `commands/` or `raw/` to run it hands-on.
