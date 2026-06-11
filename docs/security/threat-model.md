# Multi-Cloud DR Platform: Threat Model

## Threat Actors & Vectors
1. **Compromised CI/CD Pipeline:** Mitigated via OIDC federation (Zero-Trust). No static keys exist to be exfiltrated.
2. **State Manipulation:** Mitigated via GCS object versioning and public access prevention.
3. **Cross-Cloud Lateral Movement:** Mitigated via strict CIDR isolation preventing overlapping IP space.
4. **EKS Control Plane Exposure:** The Kubernetes API server must be protected from public internet scanning. Mitigated by enabling VPC-only private endpoint access for worker nodes, restricting public endpoint access to the CI/CD execution IPs (GitHub Actions).
5. **Container Escape:** Mitigated by enforcing AWS IAM Roles for Service Accounts (IRSA) rather than attaching broad IAM permissions directly to the underlying EC2 worker nodes.
6. **Data Interception in Transit:** Cross-cloud database replication exposes transaction logs to the public internet. Mitigated by enforcing strict TLS/SSL encryption on the AWS DMS endpoints and requiring certificate validation for the GCP source connection.

## High-Availability & State Threats
7. **Split-Brain Data Corruption:** * **Threat:** A partial network partition isolates GCP from the internet, but GCP remains internally active. AWS DR is triggered. Users write to AWS. The partition heals, and GCP attempts to resume processing, resulting in divergent databases.
   * **Mitigation:** Enforced by ADR 0006. DNS failover is strictly manual. Before the Incident Commander flips DNS, the AWS RDS instance is formally promoted to Primary, permanently severing the DMS replication link from GCP. When GCP recovers, it must be rebuilt from the AWS state.

8. **Rogue Autoscaling (Denial of Wallet):**
   * **Threat:** An application bug in the passive DR site causes infinite pod crashing during failover, triggering the EKS Cluster Autoscaler to request hundreds of nodes.
   * **Mitigation:** Implemented via strict IAM and EKS configurations. The Autoscaler Auto Scaling Group (ASG) is hard-capped at `max_size = 20`. AWS Budgets are configured to trigger SNS alerts if daily spend exceeds $100.
