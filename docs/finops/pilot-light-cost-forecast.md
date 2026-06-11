# FinOps Forecast: AWS Pilot Light DR Environment

## Executive Summary
This document outlines the forecasted run-rate for the AWS passive Disaster Recovery environment, ensuring strict adherence to the `< 5%` idle cost mandate for Tier 2 workloads.

## State 1: Idle (Standard Operating Procedure)
During normal operations, the AWS environment is scaled to absolute minimums to maintain state replication and network readiness.
* **Compute (EKS):** Control Plane ($73/mo) + 1x `t3.medium` worker node ($30/mo) = $103/mo
* **Network (VPC):** 1x NAT Gateway ($32/mo) + Data Processing = $40/mo
* **Database (RDS):** 1x `db.t3.micro` ($15/mo)
* **Replication (DMS):** 1x `dms.t3.micro` ($15/mo)
* **Total Estimated Idle Run-Rate:** **~$173.00 / month**

## State 2: Active Disaster (Failover Executed)
During a total GCP regional failure, the AWS environment dynamically scales to match production traffic.
* **Compute (EKS):** Autoscaler provisions 20x `m5.large` nodes = ~$1,400/mo (prorated by the hour)
* **Database (RDS):** Scaled to `db.r6g.xlarge` = ~$400/mo (prorated by the hour)
* **Risk Assessment:** The massive cost spike is acceptable as it only occurs during a SEV-1 corporate emergency, avoiding thousands of dollars in permanent Active-Active idle costs.
