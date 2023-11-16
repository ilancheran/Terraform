data "google_compute_disk" "ins" {
    name = "instance-1"
    zone = "us-central1-a"
}


resource "google_compute_resource_policy" "bar" {
  name   = "gce-policy"
  region = "us-central1"
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time = "7:00"
      }
    }
    retention_policy {
      max_retention_days    = 2
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      labels = {
        my_label = "value"
      }
      storage_locations = ["us"]
      guest_flush       = true
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "snap" {
  name = google_compute_resource_policy.bar.name
  disk = data.google_compute_disk.ins.name
  zone = data.google_compute_disk.ins.zone
}