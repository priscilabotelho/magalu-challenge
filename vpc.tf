provider "google" {
  project = var.project_id
  region  = var.region
}

# Cria a rede VPC apenas se não existir
resource "google_compute_network" "vpc" {
  name                    = sensitive("${var.project_id}-vpc")
  auto_create_subnetworks = false
}

# Verifica se a rede VPC já existe
data "google_compute_network" "existing_vpc" {
  count = length(google_compute_network.vpc) > 0 ? 1 : 0
  name  = google_compute_network.vpc.name  # Referência direta ao nome da rede VPC
}

# Cria a subrede apenas se não existir
resource "google_compute_subnetwork" "subnet" {
  name          = sensitive("${var.project_id}-subnet")
  region        = var.region
  network       = google_compute_network.vpc.name  # Referência direta ao nome da rede VPC
  ip_cidr_range = "10.10.0.0/24"

  # Condicional para criar apenas se o recurso não existir
  count = length(data.google_compute_network.existing_vpc) == 0 ? 1 : 0
}

# Verifica se a subrede já existe
data "google_compute_subnetwork" "existing_subnet" {
  count   = length(google_compute_subnetwork.subnet) > 0 ? 1 : 0
  name    = google_compute_subnetwork.subnet.name  # Referência direta ao nome da subrede
  region  = var.region
  network = google_compute_network.vpc.name  # Referência direta ao nome da rede VPC
}
