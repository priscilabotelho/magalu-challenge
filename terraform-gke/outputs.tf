output "region" {
  value       = var.region
  description = "Região do GCloud"
}

output "project_id" {
  value       = var.project_id
  description = "ID do projeto GCP"
  sensitive   = true
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.magalu_cluster.name
  description = "Nome do cluster GKE"
  sensitive   = true
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.magalu_cluster.endpoint
  description = "Host do cluster GKE"
  sensitive   = true
}