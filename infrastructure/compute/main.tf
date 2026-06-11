provider "aws" {
  region = "us-west-2"
}

# Dynamically look up the VPC and Subnets created in the Network module
data "aws_vpc" "dr_vpc" {
  tags = {
    Name = "mcdrp-passive-dr"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dr_vpc.id]
  }
  tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "mcdrp-passive-eks"
  cluster_version = "1.30"

  vpc_id                   = data.aws_vpc.dr_vpc.id
  subnet_ids               = data.aws_subnets.private.ids
  control_plane_subnet_ids = data.aws_subnets.private.ids

  # Threat Model Mitigation: Secure API Server Access
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    pilot_light_node = {
      instance_types = ["t3.medium"]

      # FinOps Mandate: Scale-to-Zero capability (1 node for CoreDNS)
      min_size     = 1
      max_size     = 20
      desired_size = 1
    }
  }

  # Enable IRSA for zero-trust pod identities
  enable_irsa = true
}
