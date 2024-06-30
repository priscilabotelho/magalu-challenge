output "kubernetes_cluster_name" {
  value = google_container_cluster.magalu_challenge.name
}

output "kubernetes_cluster_endpoint" {
  value = google_container_cluster.magalu_challenge.endpoint
}

output "kubernetes_cluster_master_auth" {
  value = google_container_cluster.magalu_challenge.master_auth
}