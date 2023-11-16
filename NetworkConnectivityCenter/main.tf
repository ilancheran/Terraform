data "google_compute_network" "vpc-a" {
  name = "vpc-a"
}

data "google_compute_network" "vpc-b" {
  name = "vpc-b"
}

data "google_compute_subnetwork" "sub-a" {
    name = "subnet-a"
    region = "asia-east1"
}

data "google_compute_subnetwork" "sub-b" {
    name = "subnet-b"
    region = "us-central1"
}


resource "google_compute_instance" "ins-1" {
  name = "ins-1-vpc-a"
    machine_type = "n2-standard-2"
    zone = "asia-east1-a"

    boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = data.google_compute_network.vpc-a.name
    subnetwork =data.google_compute_subnetwork.sub-a.name
    access_config {
      
    }
  }
  
}

resource "google_compute_instance" "ins-2" {
    name = "ins-2-vpc-b"
    machine_type = "n2-standard-2"
    zone = "us-central1-a"

    boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = data.google_compute_network.vpc-b.name
    subnetwork =data.google_compute_subnetwork.sub-b.name
    access_config {
      
    }
  }
  
}

resource "google_compute_firewall" "allow-vpc-a" {
    depends_on = [ google_compute_instance.ins-1, google_compute_instance.ins-2 ]
    name = "ping-a-b"
    network = data.google_compute_network.vpc-b.name

    allow {
      protocol = "icmp"
    }

    direction = "INGRESS"
    source_ranges = [google_compute_instance.ins-1.network_interface.0.network_ip]
    destination_ranges = [google_compute_instance.ins-2.network_interface.0.network_ip]
  
}

resource "google_compute_firewall" "allow-vpc-b" {
    depends_on = [ google_compute_instance.ins-1, google_compute_instance.ins-2 ]
    name = "ping-b-a"
    network = data.google_compute_network.vpc-a.name

    allow {
      protocol = "icmp"
    }

    direction = "INGRESS"
    source_ranges = [google_compute_instance.ins-2.network_interface.0.network_ip]
    destination_ranges = [google_compute_instance.ins-1.network_interface.0.network_ip]
  
}



resource "google_network_connectivity_hub" "vpc-a-b" {
    name = "vpc-hub"

}

resource "google_network_connectivity_spoke" "vpc-spoke-a" {
  name = "spokes-a"
  location = "global"
  hub = google_network_connectivity_hub.vpc-a-b.id
  linked_vpc_network {
    uri = data.google_compute_network.vpc-a.self_link
  }
}

resource "google_network_connectivity_spoke" "vpc-spoke-b" {
  name = "spokes-b"
  location = "global"
  hub = google_network_connectivity_hub.vpc-a-b.id
  linked_vpc_network {
    uri = data.google_compute_network.vpc-b.self_link
  }
}