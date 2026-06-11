# ADR 0003: AWS Passive Region Network Fabric

## Context
A network boundary must be established in AWS before provisioning EKS compute. We must balance the requirement for a production-ready network topology against the FinOps mandate to minimize idle DR costs (Run-rate < 5% of primary).

## Decision
We will utilize the official `terraform-aws-modules/vpc/aws` module to provision a custom VPC in `us-west-2` with the following parameters:
* **CIDR Isolation:** `10.99.0.0/18` (Ensures zero collision with GCP primary networks).
* **FinOps Optimization:** `single_nat_gateway = true`. We will deploy only one NAT gateway instead of one per Availability Zone (AZ). 

## Consequences
* **Positive (Financial):** Eliminates the hourly cost of two redundant NAT Gateways while the DR site is idle, adhering to the Tier 2 Pilot Light constraints.
* **Negative (Technical):** If the specific AZ hosting the single NAT gateway fails concurrently with the GCP primary region, egress traffic from the DR site will drop.
* **Translation:** We accept the single-AZ NAT risk because AWS AZ failures are historically independent of GCP regional failures, and the cost savings justify the theoretical edge-case risk for a Tier 2 workload.
