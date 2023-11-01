# jenkins

provider "google" {
  project     = "boris-temp-for-lab"
  region      = "europe-central2"
}

resource "google_compute_network" "vpc" {
  name                    = "jenkins-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "jenkins-subnet"
  region        = "europe-central2"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_firewall" "allow_traffic" {
  name    = "allow-ssh-http-8080"
  network = google_compute_network.vpc.name

  // Allow SSH
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  // Allow HTTP and port 8080
  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  description   = "Allow SSH, HTTP, and port 8080 from anywhere"
}


resource "google_compute_instance" "vm" {
  name         = "jenkins-vm"
  machine_type = "e2-medium"
  zone         = "europe-central2-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link

    access_config {
      // Ephemeral IP
    }
  }
  
  metadata_startup_script = file("${path.module}/jenkins.sh")  
}

output "vm_external_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
