# Management Response to Adversarial Audit

**Author:** Brian Lasky, Senior Site Reliability Engineer & Cloud Architect
**Date:** June 11, 2026
**Framework:** SOC2 Type II / AWS Well-Architected

## Executive Summary
This document outlines the architectural decisions made in response to the June 11 Adversarial Audit. As the Principal Architect bridging CTO resilience requirements (4-Hour RTO) and CFO fiscal constraints (< 5% idle cost), findings were evaluated strictly against business impact.

## Decision Matrix

### 1. ACCEPTED & REMEDIATED
**Finding 1.2: GCS State Backend SPOF**
* **Assessment:** The auditor correctly identified that hosting the Terraform state on the primary cloud (GCP) creates a correlated failure loop during a disaster.
* **Action:** Remediated in PR/Commit. State migrated to AWS S3 with DynamoDB locking.

**Finding 2.1: DMS Encryption In-Transit Gap**
* **Assessment:** Valid SOC2 CC6.7 violation.
* **Action:** Remediated. Enforced `ssl_mode = "verify-full"` on the AWS DMS endpoints.

**Finding 2.2: OIDC Subject Claim Wildcarding**
* **Assessment:** Valid privilege escalation vector. 
* **Action:** Remediated. GitHub Actions trust policy hardened to require the explicit `dr-production` environment claim.

### 2. ACCEPTED WITH MODIFICATION
**Finding 4.1: RDS Modification Breaches RTO**
* **Assessment:** The auditor correctly identified that scaling from `t3.micro` to a production class during failover could take 90-180 minutes, threatening the 4-Hour RTO.
* **Action:** Modified. We accept the recommendation to pre-size the instance to `db.r6g.large`. However, to maintain the CFO's FinOps constraint, we reject the auditor's suggestion to make it Multi-AZ while idle. It remains Single-AZ to minimize run-rate, and will be modified to Multi-AZ *post-failover* once traffic is stabilized.

### 3. DEFERRED (PHASE 2 OPTIMIZATION)
**Finding 4.2: Replace Cluster Autoscaler with Karpenter**
* **Assessment:** Karpenter is architecturally superior for emergency mass-provisioning.
* **Action:** Deferred. Ripping out the standard EKS managed node groups to implement Karpenter introduces unacceptable Day-1 delivery delays. The Cluster Autoscaler is mathematically sufficient for a 4-Hour RTO. Karpenter is logged as the primary Q3 platform optimization target.

### 4. REJECTED (ACCEPTED BUSINESS RISK)
**Finding 1.1: Single NAT Gateway is a SPOF**
* **Assessment:** The auditor flagged the single NAT gateway as a reliability risk.
* **Action:** Rejected. The single NAT gateway was an explicit FinOps decision. For a Tier 2 workload, the statistical probability of the specific AWS Availability Zone hosting the NAT gateway failing *at the exact same moment* as the GCP primary region is astronomically low. The cost of redundant NAT gateways (~$70/month) violates the Pilot Light budget constraint for an edge-case risk. The business accepts this risk.
