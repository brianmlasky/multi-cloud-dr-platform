# ADR 0004: EKS Pilot Light Compute Strategy

## Context
The passive DR region requires a Kubernetes environment capable of receiving the failover workload from GCP. We must satisfy the 4-Hour RTO (rapid scale-up) while adhering to the FinOps mandate (< 5% idle run-rate).

## Decision
We will provision an Amazon Elastic Kubernetes Service (EKS) cluster using the `terraform-aws-modules/eks/aws` module.
* **Node Strategy:** We will utilize a Managed Node Group with `min_size = 1` and `max_size = 20`. 
* **Instance Type:** The idle node will be a cost-optimized `t3.medium`.
* **Network Integration:** The cluster will dynamically attach to the private subnets of the custom VPC defined in ADR 0003.

## Consequences
* **Positive (Financial):** The idle cost is restricted to the EKS Control Plane (~$73/mo) and a single `t3.medium` node (~$30/mo), easily satisfying the strict FinOps constraints.
* **Positive (Operational):** By keeping the control plane active, GitOps tools (e.g., ArgoCD) can continuously sync manifests, ensuring the cluster is pre-configured and ready to scale the moment the primary region fails.
* **Negative (Performance):** The initial failover will experience a 3-to-5 minute latency spike while the Cluster Autoscaler provisions the EC2 instances to handle the sudden ingress of traffic. This is fully acceptable within the 4-Hour RTO.
