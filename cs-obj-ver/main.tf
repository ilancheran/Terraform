resource "google_storage_bucket" "website" {
    name = "terraform-by-ilancheran"
    location = "US"


    versioning {
      enabled = "true"
    }
    lifecycle_rule {
    condition {
      age = 5
    }
    action {
      type = "Delete"
    }
  }
}

