const express = require("express");
const client = require("prom-client");
const cors = require("cors");

const app = express();
app.use(cors());

// Prometheus metrics setup
const register = new client.Registry();
client.collectDefaultMetrics({ register }); // Collect default system metrics (optional)

const httpRequestDurationMicroseconds = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["service", "method"],
  buckets: [0.1, 0.5, 1, 2, 5]
});
register.registerMetric(httpRequestDurationMicroseconds);

// Payment Service
app.get("/pay", (req, res) => {
  const start = Date.now();
  setTimeout(() => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDurationMicroseconds
      .labels("payment", "GET")
      .observe(duration);

    res.send("Payment processed!");
  }, Math.random() * 1000); // Simulate latency
});

// Balance Service
app.get("/balance", (req, res) => {
  const start = Date.now();
  setTimeout(() => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDurationMicroseconds
      .labels("balance", "GET")
      .observe(duration);

    res.send("Balance: $1000");
  }, Math.random() * 500); // Simulate latency
});

// Prometheus Metrics Endpoint
app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

// Start server on port 8001
app.listen(8001, () => {
  console.log("Server running on port 8001");
});