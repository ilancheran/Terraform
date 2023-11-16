data "google_compute_network" "vpc" {
    name = "vpc-a"
  
}

data "google_compute_subnetwork" "sub-1" {
  name = "sub--a"
  region = "us-central1"
}

data "google_compute_network" "vpc-1" {
    name = "vpc-b"
  
}

data "google_compute_subnetwork" "sub-2" {
    name = "sub"
    region = "us-central1"
}

resource "google_service_account" "sa" {
  account_id   = "secure-access"
  display_name = "secure access to private server"
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "user:ilancheran.muthumari@cdw.com"
  ]
}

resource "google_project_iam_binding" "compute-admin" {
  role    = "roles/compute.admin"  
  project = var.gcp_project
  members = [
    "serviceAccount:secure-access@${var.gcp_project}.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "sa-user" {
  role    = "roles/iam.serviceAccountUser"  
  project = var.gcp_project
  members = [
    "serviceAccount:secure-access@${var.gcp_project}.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "iap" {
  role    = "roles/iap.tunnelResourceAccessor"  
  project = var.gcp_project
  members = [
    "serviceAccount:secure-access@${var.gcp_project}.iam.gserviceaccount.com"
  ]
}

resource "google_compute_instance" "name" {
    name = "private-server"
    machine_type = "n2-standard-2"
    zone = "us-central1-a"

    boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = data.google_compute_network.vpc-1.name
    subnetwork = data.google_compute_subnetwork.sub-2.name
  }
  service_account {
    email = google_service_account.sa.email
    scopes = ["cloud-platform"]
  }
}


resource "google_compute_instance_template" "admin-server-gp" {
    name = "admin-server-gp"
    machine_type = "n2-standard-2"
    tags = [ "lb-health-check" , "http-server", "https-server" ]

    disk {
    disk_type = "pd-balanced"
    source_image = "projects/debian-cloud/global/images/debian-11-bullseye-v20231010"
    auto_delete  = true
    disk_size_gb = 20
    boot         = true
    type = "persistent"
    }
    
    network_interface {
      network = data.google_compute_network.vpc.name
      subnetwork = data.google_compute_subnetwork.sub-1.name
      access_config {
        
      }
    }
    service_account {
      email = google_service_account.sa.email
      scopes = ["cloud-platform"]
    }

    shielded_instance_config {
      enable_secure_boot = "false"
      enable_integrity_monitoring = "true"
      enable_vtpm = "true"
    }

    metadata_startup_script = "${file("C:/Users/ilanmut/Desktop/GCP workspace/Terraform/secure Access/startup.sh")}"
}


  
resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = 80
  }
}

resource "google_compute_autoscaler" "default" {
  name   = "my-autoscaler"
  zone   = "us-central1-a"
  target = google_compute_instance_group_manager.admin-instance-group.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60
  }
}

resource "google_compute_instance_group_manager" "admin-instance-group" {
  name = "admin-server"

  base_instance_name = "admin"
  zone               = "us-central1-a"
  

  version {
    instance_template  = google_compute_instance_template.admin-server-gp.self_link_unique
  }

  target_size  = 2

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }
}

resource "google_compute_firewall" "ssh-admin" {
    name = "ssh-admin-group"
    network = data.google_compute_network.vpc.name

    allow {
      protocol = "tcp"
      ports = [ "22" ]
    }

    direction = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    destination_ranges = [data.google_compute_subnetwork.sub-1.ip_cidr_range]
  
}

resource "google_compute_firewall" "ssh-private" {
    name = "ssh-private"
    network = data.google_compute_network.vpc-1.name

    allow {
      protocol = "tcp"
      ports = [ "22" ]
    }

    direction = "INGRESS"
    source_ranges = ["35.235.240.0/20"]
    destination_ranges = [data.google_compute_subnetwork.sub-2.ip_cidr_range]
  
}

