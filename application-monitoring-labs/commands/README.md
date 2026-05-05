# commands

This folder contains CLI commands, shell scripts, and Kubernetes manifests used across the SRE labs.

## Files

| File | Purpose |
|------|---------|
| `Auto-scaling-SelfHealing-Automation-Infra-Monitoring-learnig.md` | Step-by-step CLI history for setting up AWS CLI, Terraform, Locust load testing, and deploying self-healing infra |
| `EKS-self-healing script-Toil Reduction and Self-Healing Systems.txt` | EKS self-healing automation script — detects and recovers failing pods to reduce toil |
| `commands-learn.md` | Useful CLI commands learned during labs (tee, trivy, cat -n) with examples |
| `prerequsite.sh` | Shell script to install all prerequisites for the labs (AWS CLI, Terraform, etc.) |
| `self-healing-app.yaml` | Kubernetes manifest for deploying a self-healing application with liveness/readiness probes |

## Usage

Run the prerequisites script first on a fresh Ubuntu instance:

```bash
chmod +x prerequsite.sh
./prerequsite.sh
```

Then follow the commands in the relevant `.md` file for your lab topic.
