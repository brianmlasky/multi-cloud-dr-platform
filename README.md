# Multi-Cloud Disaster Recovery (DR) Platform

**Workload Tier:** Tier 2 (Business Critical)  
**Topology:** Active-Passive (Primary: GCP, Passive: AWS)  
**RTO Target:** 4 Hours | **RPO Target:** 15 Minutes  

## Executive Summary
This repository contains the infrastructure-as-code and architectural documentation for a FinOps-optimized, multi-cloud disaster recovery platform. It utilizes a **Pilot Light** strategy, keeping idle AWS infrastructure costs below 5% of the primary GCP environment while guaranteeing strict recovery SLAs.

This project goes beyond infrastructure provisioning, heavily emphasizing Enterprise Architecture, Fiscal SecOps, and Regulatory Compliance (SOC2/ISO 27001).

## 🗺️ The Architecture Documentation
Hiring Managers and Auditors are encouraged to review the documentation below, which outlines the system physics, threat models, and management decisions.

1. **[The Management Response Matrix](docs/security/audits/2026-06-11-management-response.md):** The Principal Architect's formal response to an adversarial security and RTO audit, detailing accepted business risks and applied remediations.
2. **[Business Continuity & FinOps Parameters](docs/architecture/business-continuity-parameters.md):** The mathematical RTO/RPO limits and the CTO/CFO translation constraints.
3. **[Security Architecture Spec & Threat Model](docs/security/threat-model.md):** STRIDE analysis, Data Classification, and split-brain corruption mitigations.
4. **[SEV-1 Disaster Runbook](docs/playbooks/disaster-runbook-gcp-to-aws.md):** The step-by-step incident response playbook detailing the human-in-the-loop failover execution.

## 🏗️ Infrastructure Modules
* `infrastructure/bootstrap/`: Multi-region S3 Terraform State and Zero-Trust GitHub Actions OIDC federation.
* `infrastructure/network/`: Non-overlapping VPC topology with S3/DynamoDB Gateway Endpoints.
* `infrastructure/compute/`: Amazon EKS Pilot Light cluster utilizing Managed Node Groups.
* `infrastructure/database/`: Asynchronous Change Data Capture (CDC) replication via AWS DMS to a pre-sized RDS PostgreSQL target.
* `infrastructure/routing/`: Amazon Route 53 Global Traffic Management and CloudWatch alerting.

## Deployment & Failover
Failover execution is strictly guarded by the Incident Commander to prevent split-brain data corruption. See the [Adversarial Game Day Playbook](docs/playbooks/adversarial-game-day.md) for Chaos Engineering and DiRT validation protocols.
