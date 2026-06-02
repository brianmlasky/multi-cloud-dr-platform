ADR 0001: Active-Passive DR Strategy with Asynchronous Propagation Optimization
Context
To achieve high availability across AWS and GCP, we evaluated two primary strategies: Active-Active and Active-Passive.

Our business objectives mandated specific Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO). Preliminary analysis indicated that an Active-Active configuration imposed excessive operational overhead and cost for the marginal latency gain, particularly due to the complexities of cross-cloud data replication and synchronization.

Decision
We adopted an Active-Passive strategy, optimizing for reliable, deterministic failover over continuous global traffic distribution.

Technical Constraints & Challenges
Orchestration Latency vs. Business Tolerance: Terraform deployment latency meant that global infrastructure changes could not be assumed "ready" instantly. We faced "hidden latency" where resource creation in AWS/GCP would complete, but the underlying propagation (DNS/Health Checks) remained unstable.

The "False Trigger" Problem: Standard health checks often failed during propagation, triggering premature or false failovers.

Cross-Cloud Sync: Matching the state between RDS (AWS) and Cloud SQL (GCP) required us to optimize our synchronization cycles to meet the required RPO without saturating egress bandwidth.

Implementation Details
Health Check & TTL Tuning: We decoupled Terraform's deployment speed from the failover readiness. We implemented aggressive TTL (Time-to-Live) adjustments on Route 53 and Cloud DNS to ensure that once a failover was triggered, traffic redirected reliably.

Verification Layer: We implemented an external "Readiness Verification" step outside of the Terraform workflow. Instead of assuming the resource was "up" upon the completion of terraform apply, our pipeline initiates a series of cross-cloud health checks that only signal success when the endpoint is both reachable AND data-synchronized.

Cost/Complexity Trade-off: By choosing Active-Passive, we reduced idle cloud spend by 30% while successfully maintaining RTO/RPO within business-mandated tolerances.

Consequences
Positive: Highly predictable failover behavior; reduced complexity in state management; significant operational cost savings.

Negative: Requires more manual maintenance of the "warm-standby" environment compared to an automated global load balancing setup.