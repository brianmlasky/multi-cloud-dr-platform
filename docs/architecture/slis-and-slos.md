# Reliability Engineering: Service Level Specifications

This document defines the mathematical operational thresholds for the Multi-Cloud Disaster Recovery Platform's control plane and replication data plane.

## 1. Global Routing (Route 53)
* **SLI:** The percentage of HTTP 200 responses from the GCP Primary ingress evaluated by the AWS Route 53 Health Check over a rolling 5-minute window.
* **SLO:** 99.9% 
* **Error Budget Action:** If SLO is breached, the `CRITICAL-GCP-Primary-Offline` CloudWatch alarm fires, initiating the SEV-1 Escalation Path.

## 2. Asynchronous Data Replication (AWS DMS)
* **SLI:** The CDC Replication Lag (measured in seconds) between the GCP source database and the AWS RDS target database.
* **SLO:** 99.0% of the time, replication lag must be < 900 seconds (15 Minutes).
* **Error Budget Action:** If lag exceeds 15 minutes, an automated PagerDuty alert is routed to the on-call Database Reliability Engineer (DBRE) to investigate network transit bottlenecks before a disaster event occurs.
