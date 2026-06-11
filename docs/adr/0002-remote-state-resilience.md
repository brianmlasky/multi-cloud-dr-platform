# ADR 0002: Multi-Region Remote State Resilience

## Context
In our Active-Passive multi-cloud DR strategy (per ADR 0001, Primary: GCP, Passive: AWS), the inability to access Terraform state during a primary region failure prevents the automated failover to AWS. Storing state in a single-region backend introduces a single point of failure (SPOF) that violates the platform's Recovery Time Objective (RTO).

## Decision
We will utilize Google Cloud Storage (GCS) configured with `MULTI_REGION` location type for the primary Terraform state backend. 
* **State Availability:** The state file will automatically replicate across US regions, ensuring it remains accessible to GitHub Actions even if the primary compute region (GCP us-central1) fails.
* **Multi-Cloud Enablement:** This highly available state allows Terraform to seamlessly execute the failover provisioning into the passive AWS environment.

## Consequences
* **Positive:** State survives regional outages, enabling automated failover CI pipelines to execute immediately against AWS.
* **Negative:** Slight latency increase during `terraform apply` operations due to multi-region replication.
