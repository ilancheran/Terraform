data "google_compute_network" "vpc" {
    name = "vpc-a"
  
}

data "google_compute_subnetwork" "sub-1" {
  name = "sub--a"
  region = "us-central1"
}



resource "google_compute_instance" "pub" {
    name = "pub-server"
    machine_type = "n2-standard-2"
    zone = "us-central1-a"
    tags = [ "http-server", "https-server" ]

    boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = data.google_compute_network.vpc.name
    subnetwork =data.google_compute_subnetwork.sub-1.name
    access_config {
      
    }
  }
  service_account {
    email = "512494308802-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = "${file("C:/Users/ilanmut/OneDrive - CDW/Desktop/GCP workspace/Terraform/cert-upon-boot/startup.sh")}"
}

