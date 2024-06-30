variable "gke_num_nodes" {
  default     = 2
  description = "numero de nodes para o cluster"
}

variable "project_id" {
  description = "project id"
  default =   "magalu-challenge"
}

variable "region" {
  description = "region"
  default =   "us-central1"
}