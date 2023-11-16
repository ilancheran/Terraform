data "archive_file" "source" {
  type = "zip"
  source_dir = "C:/Users/ilanmut/Desktop/GCP workspace/cloud functions/Allow-if-micro-or-small/"
  output_path = "C:/Users/ilanmut/Desktop/GCP workspace/cloud function zip/Allow-if-micro-or-small.zip"
}

resource "google_storage_bucket" "cs-zip" {
  name = "cloud-storage-cf-zip-files"
  location = "US"
}

resource "google_storage_bucket_object" "obj" {
  name = "Allow-if-micro-or-small.zip"
  bucket = google_storage_bucket.cs-zip.name
  source = "C:/Users/ilanmut/Desktop/GCP workspace/cloud function zip/Allow-if-micro-or-small.zip"
}

resource "google_service_account" "sa" {
  account_id   = "invoke"
  display_name = "invoke cloud function"
}


resource "google_project_iam_binding" "invoker" {
  role    = "roles/run.invoker" 
  project = var.gcp_project
  members = [
    "serviceAccount:${google_service_account.sa.email}"
  ]
}

resource "google_project_iam_binding" "eventarc-admin" {
  role    = "roles/eventarc.admin" 
  project = var.gcp_project
  members = [
    "serviceAccount:${google_service_account.sa.email}"
  ]
}

resource "google_project_iam_binding" "eventarc-receiver" {
  role    = "roles/eventarc.eventReceiver" 
  project = var.gcp_project
  members = [
    "serviceAccount:${google_service_account.sa.email}"
  ]
}

resource "google_cloudfunctions2_function" "fun" {
  name = "allow_if_micro_or_small"
  location = "us-central1"
  depends_on = [ google_project_iam_binding.invoker, google_project_iam_binding.eventarc-admin, google_project_iam_binding.eventarc-receiver ]
  build_config {
    runtime = "python311"
    entry_point = "allow_if_micro_or_small"
    source {
      storage_source {
        bucket = google_storage_bucket.cs-zip.name
        object = google_storage_bucket_object.obj.name
      }
    }
  }
  service_config {
    max_instance_count = 1
    available_memory = "256M"
    timeout_seconds = 60
  }
  
 event_trigger {
    trigger_region        = "us-central1"
    event_type            = "google.cloud.audit.log.v1.written"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.sa.email
    event_filters {
      attribute = "serviceName"
      value = "compute.googleapis.com"
    }
    event_filters {
        attribute = "methodName"
        value = "beta.compute.instances.insert"
    }
 }
}

