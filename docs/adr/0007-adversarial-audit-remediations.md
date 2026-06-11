# ADR 0007: Adversarial Audit Remediations (SOC2 & RTO Fixes)

## Context
An adversarial architecture audit identified critical RTO breaches and SOC2/ISO 27001 compliance gaps in the initial Pilot Light design. Specifically: GCS as a state backend creates a correlated failure risk, RDS instance class modification times breach the 4-Hour RTO, and OIDC/DMS lacked strict cryptographic boundaries.

## Decisions
1. **Control Plane Relocation:** Terraform state is migrated from GCP GCS to AWS S3. If GCP fails, the Infrastructure-as-Code pipeline must not rely on GCP's API to execute the failover.
2. **OIDC Hardening:** GitHub Actions IAM trust policies are now strictly scoped to the `dr-production` environment, eliminating wildcard branch escalation vectors.
3. **Data Plane RTO Guarantee:** The AWS RDS target is pre-sized to `db.r6g.large` (Single-AZ to manage FinOps constraints) rather than `t3.micro`. This eliminates the 90-180 minute instance modification delay, guaranteeing the 4-Hour RTO while absorbing a minor idle cost increase.
4. **Data in Transit:** AWS DMS is strictly enforced with `ssl_mode = "verify-full"` to satisfy SOC2 CC6.7.
