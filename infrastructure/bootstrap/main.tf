terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket         = "mcdrp-tf-state-aws-primary"
    key            = "dr-platform/aws/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dr"
  }
}

provider "aws" {
  region = "us-west-2"
}

# S3 State Bucket (Compliance Hardened)
resource "aws_s3_bucket" "tfstate" {
  bucket = "mcdrp-tf-state-aws-primary"
  lifecycle { prevent_destroy = true }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration { status = "Enabled" }
}

# DynamoDB Lock Table
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = "terraform-state-lock-dr"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
