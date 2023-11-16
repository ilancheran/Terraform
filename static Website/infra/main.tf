# Bucket to store website

resource "google_storage_bucket" "website" {
    name = "terraform-by-ilancheran"
    location = "US"
}

# Make new object public

resource "google_storage_object_access_control" "public_rule" {
    object = google_storage_bucket_object.static_site.name
    bucket = google_storage_bucket.website.name
    role = "READER"
    entity = "allUsers"
}

# upload the html file to the bucket

resource "google_storage_bucket_object" "static_site" {
    name = "index.html"
    source = "C:/Users/ilanmut/Desktop/GCP workspace/Terraform/static Website/website/index.html"
    bucket = google_storage_bucket.website.name
}
