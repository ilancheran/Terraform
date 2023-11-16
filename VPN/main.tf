# get the vpc-1 data
data "google_compute_network" "vpc-1" {
  name = "vpc-a"

}

#get the vpc-2 data
data "google_compute_network" "vpc-2" {
  name = "vpc-b"
}

#create vpn gateway for vpc-1
resource "google_compute_vpn_gateway" "gw1" {
    name = "vpn-gw-1"
    network = data.google_compute_network.vpc-1.name
}

#reserve an external ip for vpn-gw-1
resource "google_compute_address" "gw1-ip" {
  name = "gw1-ip"
}

#create vpn gateway for vpc-2
resource "google_compute_vpn_gateway" "gw2" {
    name = "vpn-gw-2"
    network = data.google_compute_network.vpc-2.name
}

#reserve an external ip for vpn-gw-2
resource "google_compute_address" "gw2-ip" {
  name = "gw2-ip"
}

# create forwarding rule for gw-1
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.gw1-ip.address
  target      = google_compute_vpn_gateway.gw1.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.gw1-ip.address
  target      = google_compute_vpn_gateway.gw1.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.gw1-ip.address
  target      = google_compute_vpn_gateway.gw1.id
}


# create forwarding rule for gw-2
resource "google_compute_forwarding_rule" "fr_esp-2" {
  name        = "fr-esp-2"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.gw2-ip.address
  target      = google_compute_vpn_gateway.gw2.id
}

resource "google_compute_forwarding_rule" "fr_udp500-2" {
  name        = "fr-udp500-2"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.gw2-ip.address
  target      = google_compute_vpn_gateway.gw2.id
}

resource "google_compute_forwarding_rule" "fr_udp4500-2" {
  name        = "fr-udp4500-2"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.gw2-ip.address
  target      = google_compute_vpn_gateway.gw2.id
}


#create a tunnel for gw-1
resource "google_compute_vpn_tunnel" "tunnel1" {
  name          = "tunnel1"
  peer_ip       = google_compute_address.gw2-ip.address
  shared_secret = "a secret message"

  target_vpn_gateway = google_compute_vpn_gateway.gw1.id
  local_traffic_selector = [ "0.0.0.0/0" ]
 

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

#create a tunnel for gw-2
resource "google_compute_vpn_tunnel" "tunnel2" {
  name          = "tunnel2"
  peer_ip       = google_compute_address.gw1-ip.address
  shared_secret = "a secret message"

  target_vpn_gateway = google_compute_vpn_gateway.gw2.id
  local_traffic_selector = [ "0.0.0.0/0" ]
 

  depends_on = [
    google_compute_forwarding_rule.fr_esp-2,
    google_compute_forwarding_rule.fr_udp500-2,
    google_compute_forwarding_rule.fr_udp4500-2,
  ]
}

#create a route for vpc-1
resource "google_compute_route" "route1" {
  name       = "route1"
  network    = data.google_compute_network.vpc-1.name
  dest_range = "10.0.6.0/24"
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.id
}

#create a route for vpc-2
resource "google_compute_route" "route2" {
  name       = "route2"
  network    = data.google_compute_network.vpc-2.name
  dest_range = "172.16.0.0/22"
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel2.id
}
