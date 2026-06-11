# ADR 0002: Multi-Region Remote State Resilience

## Context
In our Active-Passive multi-cloud DR strategy (per ADR 0001), the inability to access Terraform state during a primary region failure prevents failover execution. Storing state in a single-region backend introduces a single point of failure (SPOF) that violates the platform's Recovery Time Objective (RTO).

## Decision
We will utilize Google Cloud Storage (GCS) configured with `MULTI_REGION` location type (e.g., `US` multi-region) for the primary Terraform state backend. 
* **Versioning:** Object versioning is strictly enforced to prevent state corruption.
* **Encryption:** Managed via GCP KMS with rotation policies.
* **Identity:** CI/CD execution will authenticate exclusively via Workload Identity Federation (WIF).

## Consequences
* **Positive:** State survives regional outages, enabling automated failover CI pipelines to execute immediately against the passive AWS environment.
* **Negative:** Slight latency increase during `terraform apply` operations due to multi-region replication.
