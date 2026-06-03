# ADR 0001: Active-Passive DR Strategy with Asynchronous Propagation Optimization

## Context
To achieve high availability across AWS and GCP, we evaluated two primary strategies: Active-Active and Active-Passive.

## Decision
We adopted an Active-Passive strategy, optimizing for reliable, deterministic failover over continuous global traffic distribution.

## Technical Constraints & Challenges
- **Orchestration Latency:** Terraform deployment latency meant that global infrastructure changes could not be assumed "ready" instantly.
- **The "False Trigger" Problem:** Standard health checks often failed during propagation.
- **Cross-Cloud Sync:** Matching the state between RDS and Cloud SQL required optimized synchronization to meet RPO without saturating egress bandwidth.

## Implementation Details
- **Health Check & TTL Tuning:** Decoupled deployment speed from failover readiness using aggressive DNS TTLs.
- **Verification Layer:** Implemented an external "Readiness Verification" step outside of the Terraform workflow.

## Consequences
- **Positive:** Highly predictable failover; reduced complexity in state management; 30% reduction in idle cloud spend.
- **Negative:** Requires manual maintenance of the "warm-standby" environment.
