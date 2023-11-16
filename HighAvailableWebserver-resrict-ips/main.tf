data "google_compute_network" "vpc" {
    name = "vpc-a"
  
}

data "google_compute_subnetwork" "sub-1" {
  name = "sub--a"
  region = "us-central1"
}


resource "google_compute_instance_template" "web-temp" {
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

resource "google_compute_region_autoscaler" "default" {
  name   = "my-autoscaler"
  region = "us-central1"
  target = google_compute_region_instance_group_manager.web-server.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60
  }
}

resource "google_compute_region_instance_group_manager" "web-server" {
  name = "web-server"

  base_instance_name = "web-server"
  distribution_policy_zones = [ "us-central1-a", "us-central1-f","us-central1-c","us-central1-b" ]
  

  version {
    instance_template  = google_compute_instance_template.web-temp.self_link_unique
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


resource "google_compute_backend_service" "bs" {
  name = "bs"
  protocol = "HTTP"
  health_checks = [ google_compute_health_check.autohealing.self_link ]
  load_balancing_scheme = "EXTERNAL"
  backend {
    group = google_compute_region_instance_group_manager.web-server.instance_group
  }
}


# http proxy
resource "google_compute_target_http_proxy" "default" {
  name     = "l7-xlb-target-http-proxy"
  url_map  = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  name            = "l7-xlb-url-map"
  default_service = google_compute_backend_service.bs.id
}

resource "google_compute_global_address" "ip" {
  name = "ipp"
}


resource "google_compute_global_forwarding_rule" "fw" {
    name = "fw-rule"
    ip_protocol = "TCP"
    load_balancing_scheme = "EXTERNAL"
    port_range = "80"
    target = google_compute_target_http_proxy.default.id
    ip_address = google_compute_global_address.ip.address
  
}

resource "google_compute_firewall" "name" {
  name = "restrict-ip"
  direction = "INGRESS"
  network = data.google_compute_network.vpc.name
  deny {
    ports = [ "80", "8080" ]
    protocol = "tcp"
  }
  source_ranges = [ "36.226.253.84/32" ]
  destination_ranges = [ data.google_compute_subnetwork.sub-1.ip_cidr_range ]
}