provider "google" {
  project = var.project_id
  region  = var.region
}

# Verifica se a VPC já existe
data "google_compute_network" "existing_vpc" {
  name = "${var.project_id}-vpc"
}

# Cria a VPC apenas se não existir
resource "google_compute_network" "vpc" {
  count                   = length(data.google_compute_network.existing_vpc) == 0 ? 1 : 0
  name                    = sensitive("${var.project_id}-vpc")
  auto_create_subnetworks = false
}

# Verifica se a subnet já existe
data "google_compute_subnetwork" "existing_subnet" {
  name    = "${var.project_id}-subnet"
  region  = var.region
  network = google_compute_network.vpc[count.index].name
}

# Cria a subnet apenas se não existir
resource "google_compute_subnetwork" "subnet" {
  count         = length(data.google_compute_subnetwork.existing_subnet) == 0 ? 1 : 0
  name          = sensitive("${var.project_id}-subnet")
  region        = var.region
  network       = google_compute_network.vpc[count.index].name
  ip_cidr_range = "10.10.0.0/24"
}
