resource "google_os_config_patch_deployment" "patch" {
    patch_deployment_id = "patch-deploy"

    instance_filter {
      group_labels {
        labels = {patch = "true"}
      }
      zones = [ "us-central1-a", "us-central1-c" ]
    }

    patch_config {
      apt {
        type = "UPGRADE"
      }
    }
    duration = "10s"

    recurring_schedule {
      time_zone {
        id = "Asia/Calcutta"
        
      }
      time_of_day {
        hours = 5
        minutes = 0
        seconds = 0
        nanos = 0
      }
      weekly {
        day_of_week = "SUNDAY"
      }
    }

    rollout {
      mode = "ZONE_BY_ZONE"
      disruption_budget {
        fixed = 1
      }
    } 
}