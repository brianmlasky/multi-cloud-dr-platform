# ADR 0005: Asynchronous Data Replication Strategy

## Context
The passive AWS EKS compute cluster requires access to stateful application data (15-Minute RPO) upon failover. Synchronous Active-Active replication was rejected due to unacceptable cross-cloud latency impacts on the primary GCP workload and prohibitive egress costs.

## Decision
We will implement an Active-Passive asynchronous replication topology using AWS Database Migration Service (DMS) Change Data Capture (CDC).
* **Target Database:** Amazon RDS for PostgreSQL.
* **Pilot Light Sizing:** The passive RDS instance will operate as a `db.t3.micro` to satisfy the < 5% idle FinOps constraint. Upon failover execution, it will be dynamically scaled to production sizing.
* **Transport:** AWS DMS will continuously tail the primary GCP database WAL (Write-Ahead Log) and stream updates to the AWS RDS target.

## Consequences
* **Positive (Financial):** Idle database costs are reduced to pennies per hour while maintaining the 15-minute RPO.
* **Positive (Performance):** Zero latency impact on the primary GCP database transactions.
* **Negative (Operational):** Up to 15 minutes of data loss (RPO) is accepted in the event of a sudden, total loss of the GCP primary region.
