# GCP Provider

provider "google" {
  credentials = file(var.gcp_svc_key)
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = "us-central1-a"
}

provider "google-beta" {
  alias       = "beta"
  credentials = file(var.gcp_svc_key)
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = "us-central1-a"
}