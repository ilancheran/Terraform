data "google_compute_network" "vpc" {
    name = "vpc-a"
  
}

data "google_compute_subnetwork" "sub-1" {
  name = "sub--a"
  region = "us-central1"
}



resource "google_compute_instance" "ins1" {
  name = "instance-2"
  machine_type = "n2-standard-2"
  zone = "us-central1-a"
  tags = [ "lb-health-check" , "http-server", "https-server" ]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
    }
    
    network_interface {
      network = data.google_compute_network.vpc.name
      subnetwork = data.google_compute_subnetwork.sub-1.name
      access_config {
        
      }
    }
    metadata = {
  load-balancing-weight = "500"
}
   metadata_startup_script = "${file("C:/Users/ilanmut/Desktop/GCP workspace/Terraform/weighted-lb/ins1.sh")}"
}



resource "google_compute_instance" "ins2" {
  name = "instance-3"
  machine_type = "n2-standard-2"
  zone = "us-central1-a"
  tags = [ "lb-health-check" , "http-server", "https-server" ]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
    }
    
    network_interface {
      network = data.google_compute_network.vpc.name
      subnetwork = data.google_compute_subnetwork.sub-1.name
      access_config {
        
      }
    }
    metadata = {
  load-balancing-weight = "500"
}
   metadata_startup_script = "${file("C:/Users/ilanmut/Desktop/GCP workspace/Terraform/weighted-lb/ins2.sh")}"
}


resource "google_compute_instance_group" "webservers" {
  name        = "terraform-webservers"
  description = "Terraform test instance group"

  instances = [
    google_compute_instance.ins1.id,
    google_compute_instance.ins2.id,
  ]

  named_port {
    name = "http"
    port = "80"
  }

  zone = "us-central1-a"
}

 
resource "google_compute_region_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  region = var.gcp_region

  http_health_check {
    port = 80
  }
}


resource "google_compute_region_backend_service" "bs" {
  name = "bs"
  protocol = "TCP"
  region = "us-central1"
  health_checks = [ google_compute_region_health_check.autohealing.self_link ]
  load_balancing_scheme = "EXTERNAL"
  locality_lb_policy = "WEIGHTED_MAGLEV"
  backend {
    group = google_compute_instance_group.webservers.id
  }
}

resource "google_compute_address" "ip-me" {
    name = "ippp"
    region = var.gcp_region
}

resource "google_compute_forwarding_rule" "fw-lb" {
    name = "fwp"
    ports = [ "80" ]
    ip_address = google_compute_address.ip-me.address
    backend_service = google_compute_region_backend_service.bs.id
  
}