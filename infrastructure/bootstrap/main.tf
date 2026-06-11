terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  # Project ID injected via environment variables in CI
}

# The Multi-Region State Bucket
resource "google_storage_bucket" "dr_state_bucket" {
  name          = "mcdrp-tf-state-global-primary"
  location      = "US" # Multi-region
  force_destroy = false

  versioning {
    enabled = true
  }

  public_access_prevention = "enforced"
}
