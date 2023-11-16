resource "google_monitoring_notification_channel" "basic" {
  display_name = "Test Notification Channel"
  type         = "email"
  labels = {
    email_address = "ilancheran.muthumari@cdw.com"
  }
  force_delete = false
}

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "My Alert Policy"
  combiner     = "OR"
  
  notification_channels = [
    google_monitoring_notification_channel.basic.id
  ]
  conditions {
    display_name = "large instance alert"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/cpu/guest_visible_vcpus\" AND resource.type=\"gce_instance\""
      duration   = "0s"
      comparison = "COMPARISON_GT"
      threshold_value = 3
      trigger {
        count = 1
      }
      aggregations {
        alignment_period      = "60s"
        cross_series_reducer  = "REDUCE_NONE"
        per_series_aligner    = "ALIGN_MEAN"
      }
    }
    
  }

}