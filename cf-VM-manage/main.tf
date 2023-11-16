data "archive_file" "source" {
  type        = "zip"
  source_dir  = "C:/Users/ilanmut/Desktop/GCP workspace/cloud functions/VM-manage/"
  output_path = "C:/Users/ilanmut/Desktop/GCP workspace/cloud function zip/vm-manage.zip"
}

resource "google_storage_bucket" "cs-zip" {
  name     = "cloud-storage-cf-zip-files"
  location = "US"
}

resource "google_storage_bucket_object" "obj" {
  name   = "vm-manage.zip"
  bucket = google_storage_bucket.cs-zip.name
  source = "C:/Users/ilanmut/Desktop/GCP workspace/cloud function zip/vm-manage.zip"
}


resource "google_cloudfunctions_function" "function" {
  name    = "vm-manage"
  runtime = "python311"

  available_memory_mb = 128
  # Gets a string bucket name or a reference to a resource
  source_archive_bucket = google_storage_bucket.cs-zip.name
  source_archive_object = google_storage_bucket_object.obj.name
  trigger_http          = true
  entry_point           = "start_stop_vms"
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:tf-sa-cloudfuv1-cloudschedu@ilamut-project.iam.gserviceaccount.com"
}


resource "google_cloud_scheduler_job" "vm-manage-start" {
  name      = "8am-vm-start"
  schedule  = "0 8 * * *"
  time_zone = "IST"
  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions_function.function.https_trigger_url
    oidc_token {
      service_account_email = "tf-sa-cloudfuv1-cloudschedu@ilamut-project.iam.gserviceaccount.com"
    }
  }

}


resource "google_cloud_scheduler_job" "vm-manage-stop" {
  name      = "5pm-vm-stop"
  schedule  = "0 17 * * *"
  time_zone = "IST"
  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions_function.function.https_trigger_url
    oidc_token {
      service_account_email = "tf-sa-cloudfuv1-cloudschedu@ilamut-project.iam.gserviceaccount.com"
    }
  }

}