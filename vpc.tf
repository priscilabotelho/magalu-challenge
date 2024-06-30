provider "google" {
  project = var.project_id
  region  = var.region
}

# Verifica se a rede VPC já existe
data "google_compute_network" "existing_vpc" {
  name = sensitive("${var.project_id}-vpc")
}

# Cria a rede VPC apenas se não existir
resource "google_compute_network" "vpc" {
  name                    = sensitive("${var.project_id}-vpc")
  auto_create_subnetworks = false

  # Condicional para criar apenas se o recurso não existir
  count = length(data.google_compute_network.existing_vpc) == 0 ? 1 : 0
}

# Verifica se a subrede já existe
data "google_compute_subnetwork" "existing_subnet" {
  name    = sensitive("${var.project_id}-subnet")
  region  = var.region
  network = google_compute_network.vpc.name
}

# Cria a subrede apenas se não existir
resource "google_compute_subnetwork" "subnet" {
  name          = sensitive("${var.project_id}-subnet")
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"

  # Condicional para criar apenas se o recurso não existir
  count = length(data.google_compute_subnetwork.existing_subnet) == 0 ? 1 : 0
}
