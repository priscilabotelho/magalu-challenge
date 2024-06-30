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
  name                    = sensitive("${var.project_id}-vpc")
  auto_create_subnetworks = false

  lifecycle {
    ignore_changes = [auto_create_subnetworks]
  }

  # Usa o count apenas se a VPC ainda não existir
  count = length(data.google_compute_network.existing_vpc) == 0 ? 1 : 0
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = sensitive("${var.project_id}-subnet")
  region        = var.region
  network       = google_compute_network.vpc[0].self_link  # Referencia a VPC criada ou existente
  ip_cidr_range = "10.10.0.0/24"
}
