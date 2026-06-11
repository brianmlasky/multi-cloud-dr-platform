provider "aws" {
  region = "us-west-2"
}

locals {
  name     = "mcdrp-passive-dr"
  vpc_cidr = "10.99.0.0/18"
  azs      = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = ["10.99.0.0/22", "10.99.4.0/22", "10.99.8.0/22"]
  public_subnets  = ["10.99.48.0/24", "10.99.49.0/24", "10.99.50.0/24"]

  # FinOps constraint applied: Single NAT Gateway to minimize idle cost
  enable_nat_gateway     = true
  single_nat_gateway     = true 
  one_nat_gateway_per_az = false

  # Tagging for future EKS ALB integration
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# AUDIT FIX: Gateway Endpoints ensure S3 and DynamoDB traffic (Terraform State & ECR layers)
# never traverse the single NAT gateway, preventing scale-up failure.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.us-west-2.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids
}
