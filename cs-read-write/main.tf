data "google_storage_bucket" "cs" {
    name = "ilamut-project"
  
}
resource "google_storage_bucket_iam_binding" "viewer" {
  bucket = data.google_storage_bucket.cs.name
  role = "roles/storage.objectViewer"
  members = [
    "user:surajkumar.shettigar@cdw.com",
  ]
}

resource "google_storage_bucket_iam_binding" "writer" {
  bucket = data.google_storage_bucket.cs.name
  role = "roles/storage.objectCreator"
  members = [
    "user:rajalakshmiganesh.babu@cdw.com",
  ]
}