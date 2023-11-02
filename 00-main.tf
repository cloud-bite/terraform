terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
  backend "gcs" {
    bucket = "terraform_project"
    prefix = "terraform/state"
  }
}

resource "google_storage_bucket" "default" {
  name          = "terraform_project"
  location      = "us"
  force_destroy = "false"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
  public_access_prevention = "enforced"
}

provider "google" {
  project = "cloud-temp-400907"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

