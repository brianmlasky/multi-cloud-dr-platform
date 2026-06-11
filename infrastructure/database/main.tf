provider "aws" { region = "us-west-2" }

data "aws_vpc" "dr_vpc" { tags = { Name = "mcdrp-passive-dr" } }
data "aws_subnets" "private" {
  filter { name = "vpc-id"; values = [data.aws_vpc.dr_vpc.id] }
  tags = { "kubernetes.io/role/internal-elb" = 1 }
}

resource "aws_db_subnet_group" "dr_database" {
  name       = "mcdrp-passive-db-subnet"
  subnet_ids = data.aws_subnets.private.ids
}

# AUDIT FIX: Pre-sized to r6g.large to eliminate 90-min RTO delay. 
# Single-AZ maintains < 5% FinOps constraint while guaranteeing RTO.
resource "aws_db_instance" "dr_target" {
  identifier           = "mcdrp-passive-postgres"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.r6g.large" 
  allocated_storage    = 100
  db_subnet_group_name = aws_db_subnet_group.dr_database.name
  skip_final_snapshot  = true
  storage_encrypted    = true
  publicly_accessible  = false
  multi_az             = false 
  
  lifecycle {
    ignore_changes = [instance_class]
  }
}

resource "aws_dms_endpoint" "gcp_source" {
  endpoint_id   = "gcp-postgresql-source"
  endpoint_type = "source"
  engine_name   = "postgres"
  # AUDIT FIX: SOC2 CC6.7 Strict TLS Enforcement
  ssl_mode      = "verify-full"
}
