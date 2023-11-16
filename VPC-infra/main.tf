resource "google_compute_network" "vpc" {
  name = "terraform-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "tf-sub-1-pub" {
  name = "tf-sub-1-pub"
  ip_cidr_range = "10.0.14.0/24"
  network = google_compute_network.vpc.name
  region = "us-central1"
}

resource "google_compute_subnetwork" "tf-sub-2-priv" {
  name = "tf-sub-2-priv"
  ip_cidr_range = "10.0.15.0/24"
  network = google_compute_network.vpc.name
  region = "us-west1"
}


resource "google_compute_instance" "pub" {
    name = "pub-server"
    machine_type = "n2-standard-2"
    zone = "us-central1-a"

    boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = google_compute_network.vpc.name
    subnetwork =google_compute_subnetwork.tf-sub-1-pub.name
    access_config {
      
    }
  }
  service_account {
    email = "vm2cs-722@ilamut-project.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}



resource "google_compute_instance" "priv" {
    name = "private-server"
    machine_type = "n2-standard-2"
    zone = "us-west1-a"

    boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.tf-sub-2-priv.name
  }
  service_account {
    email = "terraform-ilamut-project@ilamut-project.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
