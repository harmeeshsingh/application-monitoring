# application-monitoring-labs

This folder contains the core lab documentation in `main files/`. Each document covers a practical SRE or observability problem with a short example and the main tools used.

## Main Files Summary

- `active-passive setups -Incident Management and Fault Tolerance`
  - Use case: build a redundant active-passive infrastructure and failover flow.
  - Real problem: maintaining availability when a primary server fails.
  - Example: Route 53 health checks automatically switch traffic from a failed EC2 active instance to a passive instance.
  - Tools: Terraform, AWS EC2, Route 53, ELB, security groups.

- `Application Performance Monitoring`
  - Use case: set up application-level monitoring for response time, throughput, and error rates.
  - Real problem: identifying slow backend performance and service degradation.
  - Example: deploy an EC2 instance, install AWS X-Ray and CloudWatch Agent, and track request latency.
  - Tools: Terraform, AWS EC2, CloudWatch, AWS X-Ray, Node.js.

- `Auto-scaling-SelfHealing-Automation-Infra-Monitoring`
  - Use case: deploy auto-scaled infrastructure with self-healing recovery.
  - Real problem: replacing unhealthy servers automatically during traffic spikes.
  - Example: use AWS Auto Scaling and CloudWatch alarms to recreate bad instances and keep the app healthy.
  - Tools: Terraform, AWS Auto Scaling, CloudWatch, Locust, Lambda, Python.

- `Dynatrace_Observability`
  - Use case: integrate a sample app with Dynatrace for full-stack observability.
  - Real problem: correlating service metrics, logs, and traces across a deployed application.
  - Example: run a Node.js app on EC2, expose /request and /payment endpoints, and monitor them in Dynatrace.
  - Tools: Terraform, AWS EC2, Dynatrace, Node.js, Express.

- `ec2_cloudwatch_script`
  - Use case: provision EC2 with CloudWatch monitoring enabled.
  - Real problem: collecting system metrics and building dashboard visibility for infrastructure.
  - Example: deploy an EC2 instance with CloudWatch Agent configured to send CPU and memory metrics to CloudWatch.
  - Tools: Terraform, AWS EC2, CloudWatch Agent.

- `EKS-self-healing script-Toil Reduction and Self-Healing Systems`
  - Use case: deploy an EKS cluster and enable Kubernetes self-healing.
  - Real problem: ensuring containers and nodes recover automatically after failure.
  - Example: create an EKS deployment with liveness/readiness probes so failing pods restart without manual work.
  - Tools: Terraform, AWS EKS, kubectl, eksctl, Kubernetes.

- `Incident-automation-lifecycle.txt`
  - Use case: automate detection and alerting for infrastructure incidents.
  - Real problem: identifying abnormal CPU behavior and notifying the team quickly.
  - Example: create CloudWatch anomaly detection and SNS email alerts for EC2 CPU spikes.
  - Tools: Terraform, AWS EC2, CloudWatch, SNS, CloudWatch anomaly detection.

- `Log_Correlation_for_Debugging_ELK_Stack`
  - Use case: centralize log collection and correlation for debugging distributed systems.
  - Real problem: searching across application and system logs when errors occur.
  - Example: deploy an ELK stack and Filebeat, then send app logs to Elasticsearch for analysis in Kibana.
  - Tools: Terraform, AWS EC2, Elasticsearch, Logstash, Kibana, Filebeat.

- `Observability_for_Microservices_Applications.txt`
  - Use case: build observability for microservices with Prometheus and Grafana.
  - Real problem: monitoring service health, availability, and microservice metrics.
  - Example: install Prometheus, Node Exporter, and Grafana to capture metrics from multiple services.
  - Tools: Prometheus, Grafana, Node Exporter, AWS EC2.

- `Python Script to Check System Logs - Toil Reduction and Self-Healing Systems`
  - Use case: automate routine log analysis and filter critical events.
  - Real problem: reducing manual toil from scanning system logs for failures.
  - Example: run a Python script that filters `/var/log/syslog` for CRITICAL, FAILED, or WARNING entries.
  - Tools: Python, regular expressions, Linux system logs.

- `Security Incident Simulation - Incident Management`
  - Use case: simulate security incidents and automate response actions.
  - Real problem: testing incident response to high request traffic and blocking malicious IPs.
  - Example: use `hey` to generate traffic against Nginx, then block abusive IPs with a Python script.
  - Tools: Terraform, AWS EC2, Nginx, CloudWatch Agent, Python, `hey`.

- `tools.txt`
  - Use case: list prerequisite tools and explain the IaC/monitoring toolchain.
  - Real problem: preparing the environment before running the labs.
  - Example: install AWS CLI, Terraform, Ansible, and kubectl before starting the exercises.
  - Tools: AWS CLI, Terraform, Ansible, kubectl, Python.

## How to use this folder

1. Open `main files/` and choose a topic file.
2. Follow the setup steps to deploy the lab scenario.
3. Use `tools.txt` first to install prerequisites.
4. Combine the documentation here with scripts in `commands/` or `raw/` when available.
