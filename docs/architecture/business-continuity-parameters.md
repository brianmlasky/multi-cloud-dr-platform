# Business Continuity & FinOps Parameters

## Workload Classification: Tier 2 (Pilot Light)
This platform is architected using the "Pilot Light" pattern for Tier 2 (Business Critical) workloads. It balances extreme cross-cloud resilience against strict operational expenditure limits.

* **Recovery Time Objective (RTO): 4 Hours.** The maximum acceptable downtime during a total regional failure. This permits a "scale-from-zero" compute strategy in the passive region, heavily reducing idle costs.
* **Recovery Point Objective (RPO): 15 Minutes.** The maximum acceptable data loss. Achieved via asynchronous cross-cloud data replication.
* **FinOps Idle Constraint:** The passive DR environment must consume < 5% of the primary environment's monthly run-rate while in an idle state.
