# Security Architecture Specification (SAS) & Threat Model

## Data Classification Matrix
| Data Type | Rest | Transit | Classification | Handling |
| :--- | :--- | :--- | :--- | :--- |
| **Terraform State** | GCS Bucket (us-central1, us-east1) | GCP Backbone | **Restricted** | TLS 1.3, KMS Encryption, WIF Access Only |
| **Database WAL Logs** | AWS DMS Worker / RDS target | Internet (GCP to AWS) | **Confidential** | TLS 1.2+ Required, VPC Private Subnet Isolation |
| **Identity JWTs** | Ephemeral memory (GitHub Actions) | OIDC Endpoint | **Secret** | 5-Minute Expiry, Zero-Trust Condition Keys |

## STRIDE Threat Analysis
| Threat Type | Description | Platform Mitigation |
| :--- | :--- | :--- |
| **Spoofing** | Rogue CI/CD pipeline attempting to deploy infrastructure. | **Mitigated:** OIDC Subject Claims restrict access to `repo:brianmlasky/multi-cloud-dr-platform:*` exclusively. |
| **Tampering** | Modification of Terraform State to redirect network routes. | **Mitigated:** GCS Object Versioning ensures all mutations are reversible. Strict IAM policies prevent deletion. |
| **Repudiation** | An engineer manually triggers a failover without logging. | **Mitigated:** GitHub Actions `workflow_dispatch` acts as the execution boundary, enforcing immutable audit logs tied to GitHub identities. |
| **Information Disclosure** | Cross-cloud replication data intercepted in transit. | **Mitigated:** AWS DMS configured with `Require` SSL mode; traffic flows via encrypted tunnels. |
| **Denial of Service** | Rogue agent crash-loop triggers infinite ASG scaling. | **Mitigated:** EKS Managed Node Group hard-capped at `max_size = 20`. AWS Budget alerts enabled. |
| **Elevation of Privilege** | Pod breaks out to the underlying AWS EC2 worker node. | **Mitigated:** IAM Roles for Service Accounts (IRSA) enforced. EC2 Node IAM profiles contain zero application privileges. |
