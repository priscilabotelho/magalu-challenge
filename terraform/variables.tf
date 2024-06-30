variable "project" {
  description = "The project ID to deploy to"
  default     = "magalu-challenge"
}

variable "region" {
  description = "The region to deploy to"
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  default     = "magalu-cluster"
}

variable "node_count" {
  description = "The number of nodes in the Kubernetes cluster"
  default     = 1
}
