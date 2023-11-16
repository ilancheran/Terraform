#get the instance data
data "google_compute_instance" "instance" {
    name = "instance-1"
    zone = "us-central1-a"    
  
}

#create the machine image
resource "google_compute_machine_image" "image" {
    provider = google-beta.beta
    name = "golden-image"
    source_instance = data.google_compute_instance.instance.self_link
}


















