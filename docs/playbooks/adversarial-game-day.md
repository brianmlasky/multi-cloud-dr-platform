# DiRT (Disaster Recovery Testing): Game Day Protocol

## Objective
To mathematically validate the 4-Hour RTO and 15-Minute RPO without disrupting primary production traffic. Game Days will be executed quarterly.

## Chaos Injection Mechanics
**Target:** The AWS Pilot Light Environment.
We will simulate a GCP failure *logically* rather than physically destroying the primary production environment.

## Execution Steps
1. **The Blockade:** Update the AWS DMS Security Group to block inbound traffic from the GCP database. This simulates a severed cross-cloud link.
2. **Observe RPO Metrics:** Verify that the AWS RDS instance identifies the replication lag. Note the exact timestamp of the final synced transaction.
3. **The Scale-Up (Dry Run):** Execute the `dr-scale-compute.yml` GitHub Action. 
4. **Validation:** * Confirm the EKS Cluster Autoscaler successfully provisions 20 nodes within 15 minutes.
   * Confirm ArgoCD successfully syncs application pods to a `Running` state.
5. **The Rollback:** * Scale the EKS node group back down to `desired_size = 1`.
   * Re-open the AWS DMS Security Group.
   * Monitor the DMS console to ensure the replication task catches up on the buffered WAL logs from GCP.

## Success Criteria
* AWS compute scales to target capacity in under 45 minutes (well within the 4-Hour RTO).
* AWS RDS is promoted successfully without data corruption.
