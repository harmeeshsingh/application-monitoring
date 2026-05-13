# application-monitoring

A comprehensive guide and implementation for monitoring modern applications. This repository demonstrates how to set up observability stacks to track performance, health, and logs using industry-standard tools.

## 🚀 Features

- **Metrics Collection**: Real-time tracking of CPU, memory, and custom application metrics.
- **Log Aggregation**: Centralized logging for easier debugging and audit trails.
- **Distributed Tracing**: Visualize request flows across microservices.
- **Alerting**: Automated notifications based on threshold breaches.
- **Dashboards**: Pre-configured visualizations for at-a-glance system health.

## 🛠️ Tech Stack

This project utilizes the following observability tools:
- **Prometheus**: For time-series data collection and alerting.
- **Grafana**: For beautiful, interactive data visualization.
- **ELK Stack (Elasticsearch, Logstash, Kibana)**: For robust log management.
- **Jaeger/Zipkin**: For distributed tracing (optional/configurable).
- **Node Exporter**: For hardware and OS metrics.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/)
- [Node.js](https://nodejs.org/) (if running the sample app locally)
- [Kubernetes/Minikube](https://minikube.sigs.k8s.io/) (optional, for K8s deployment)

## ⚙️ Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/samreen-Lab/application-monitoring.git
   cd application-monitoring
   ```

2. **Spin up the monitoring stack:**
   ```bash
   docker-compose up -d
   ```

3. **Access the Dashboards:**
   - **Grafana**: `http://localhost:3000` (Default login: `admin/admin`)
   - **Prometheus**: `http://localhost:9090`
   - **Kibana**: `http://localhost:5601`

## 📊 Monitoring Architecture

1. **Instrumentation**: The application exposes a `/metrics` endpoint.
2. **Scraping**: Prometheus pulls data from the application at regular intervals.
3. **Storage**: Metrics are stored in a time-series database.
4. **Visualization**: Grafana queries Prometheus to display data on dashboards.

## 🛡️ Best Practices Included

- **RED Method**: Monitoring Request Rate, Errors, and Duration.
- **USE Method**: Monitoring Utilization, Saturation, and Errors for resources.
- **Health Checks**: Implementation of liveness and readiness probes.

## 🤝 Contributing

Contributions are welcome!! Please feel free to submit a Pull Request or open an issue for any feature requests or bug you found.Your efforts will bring this repo a clean and single source for entertaining the monitoring.


--------------------------------------------------------------------------------------------------------------------------

# Scaneris for the labs

## To access the content of the file go the file [AI-SRE](/AI-SRE/)
### Task 1 — Infrastructure Capacity Monitoring Setup [access-the-file](/AI-SRE/AI_capabiliity_planning.md)
Design and implement a cloud-based infrastructure monitoring workflow for compute resource utilization tracking. The solution should support automated metric collection, threshold-based alerting, and operational visibility for infrastructure health monitoring across AWS resources.

Key responsibilities:
    Configure infrastructure monitoring components
    Enable automated alerting mechanisms
    Validate monitoring accuracy under workload conditions
    Ensure operational readiness of the monitoring pipeline
    Maintain infrastructure deployment consistency using IaC practices


### Task 2 — AI-Assisted Predictive SRE Workflow [access-the-file](/AI-SRE/AI_SRE_RCA.md)
Develop a predictive operations workflow capable of identifying potential infrastructure capacity risks before service degradation occurs. The implementation should support automated analysis, scheduled execution, and proactive operational notifications aligned with SRE practices.

Key responsibilities:
    Implement serverless analysis workflow
    Establish event-driven operational automation
    Enable predictive resource utilization analysis
    Integrate notification and escalation workflow
    Validate proactive alert generation during stress scenarios
