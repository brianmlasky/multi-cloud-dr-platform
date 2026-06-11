provider "aws" {
  region = "us-west-2"
}

# Dynamically look up the VPC and Subnets
data "aws_vpc" "dr_vpc" {
  tags = { Name = "mcdrp-passive-dr" }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dr_vpc.id]
  }
  tags = { "kubernetes.io/role/internal-elb" = 1 }
}

# 1. RDS Subnet Group
resource "aws_db_subnet_group" "dr_database" {
  name       = "mcdrp-passive-db-subnet"
  subnet_ids = data.aws_subnets.private.ids
  tags       = { Name = "MCDRP Passive DR Database Subnet" }
}

# 2. Pilot Light RDS Instance (Target)
resource "aws_db_instance" "dr_target" {
  identifier           = "mcdrp-passive-postgres"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro" # FinOps: Scale-to-minimum for idle state
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.dr_database.name
  skip_final_snapshot  = true
  storage_encrypted    = true
  
  # Crucial for security: Do not expose the database to the internet
  publicly_accessible = false
}

# 3. DMS Replication Subnet Group
resource "aws_dms_replication_subnet_group" "dms_subnets" {
  replication_subnet_group_id          = "mcdrp-dms-subnet-group"
  replication_subnet_group_description = "Subnets for DMS replication instance"
  subnet_ids                           = data.aws_subnets.private.ids
}

# 4. DMS Replication Instance (The CDC Worker)
resource "aws_dms_replication_instance" "dr_replicator" {
  replication_instance_id    = "mcdrp-dms-worker"
  replication_instance_class = "dms.t3.micro" # FinOps: Pilot light sizing
  allocated_storage          = 50
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_subnets.id
  publicly_accessible        = false
}

# (Note: DMS Source/Target Endpoints and Replication Tasks would be defined here, 
# requiring the specific GCP connection strings and TLS certificates.)
