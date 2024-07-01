 
### Esta documentaçao tem como objetivo explicar as funcionalidades que foram criadas dentro do repositorio terraform-gke

### Configuração do Terraform

Este código configura o Terraform para utilizar um provedor específico.

#### Provedor Google

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.35.0"
    }
  }
}

- `required_providers:` Define os provedores necessários para o Terraform.
- `google:` Especifica que o provedor Google Cloud é necessário.
- `source:`Define a origem do provedor, que é "hashicorp/google".
- `version:` Define a versão específica do provedor a ser utilizada, neste caso, "5.35.0".
---

### Cluster GKE (`arquivo gke.tf`)

resource "google_container_cluster" "magalu_cluster" {
  name     = sensitive("${var.project_id}-gke")
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

## Explicaçao do codigo acima:
- `name`: Define o nome do cluster GKE. Aqui, sensitive() é usado para proteger o valor de ${var.project_id}-gke.
- `location:` Especifica a região onde o cluster será provisionado, definida pela variável var.region.
- `remove_default_node_pool:`Define se o node pool padrão deve ser removido (nesse caso, sim).
- `initial_node_count:` Define o número inicial de nós no cluster, neste caso, 1.
- `network e subnetwork:` Especificam a rede e a sub-rede onde o cluster será criado
---

### Node Pool Gerenciado Separadamente (`arquivo gke.tf`)

  resource "google_container_node_pool" "nodes_primarios" {
  name       = "${google_container_cluster.magalu_cluster.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.magalu_cluster.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = sensitive(var.project_id)
    }

    machine_type = "e2-micro"
    tags         = ["gke-node", sensitive("${var.project_id}-gke")]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    disk_size_gb = 30  
  }
}

## Explicaçao do codigo acima:

- `name:` Define o nome do node pool gerenciado separadamente.
- `location:` Especifica a região onde o node pool será criado, igual à região do cluster.
- `cluster:` Especifica a qual cluster GKE este node pool pertence.
- `node_count:` Define o número de nós (máquinas virtuais) neste node pool.

`Dentro de node_config, são configuradas as características dos nós do node pool:`

- `oauth_scopes:` Define as permissões OAuth que os nós terão para interagir com APIs do Google Cloud.
- `labels:` Atribui rótulos aos nós, como env.
- `machine_type:`Especifica o tipo de máquina virtual para os nós.
- `tags:` Atribui tags aos nós para identificação e controle de acesso.
- `metadata:` Configura metadados adicionais para os nós.
- `disk_size_gb:` Define o tamanho do disco em GB para cada nó no node pool.
---

### VPC (`arquivo vpc.tf`)

### Provedor Google

  provider "google" {
  project = var.project_id
  region  = var.region
}

- `project:` Define o ID do projeto Google Cloud, utilizando a variável var.project_id.
- `region:` Define a região onde os recursos serão criados, utilizando a variável var.region.
---
### Rede VPC 

- `name:` Define o nome da rede VPC. Aqui, sensitive() é usado para proteger o valor de ${var.project_id}-vpc.
- `auto_create_subnetworks:` Define se as sub-redes devem ser criadas automaticamente. Neste caso, está definido como false, indicando que as sub-redes serão criadas manualmente.
---
### Sub-rede 

- `name:` Define o nome da sub-rede. Aqui, sensitive() é usado para proteger o valor de ${var.project_id}-subnet.
- `region:` Especifica a região onde a sub-rede será criada, utilizando a variável var.region.
- `network:` Especifica a rede VPC à qual esta sub-rede pertence, utilizando o nome da rede VPC criada anteriormente.
- `ip_cidr_range:`Define o intervalo de endereços IP (CIDR) para a sub-rede, neste caso, 10.10.0.0/24.
---

### Outputs do Terraform (`arquivo outputs.tf`)

Este código define outputs para serem exibidos ao final da execução do Terraform, fornecendo informações úteis sobre a infraestrutura provisionada. 

#### Região do GCloud

output "region" {
  value       = var.region
  description = "Região do GCloud"
}

- `value:` Exibe o valor da variável var.region, que contém a região onde os recursos foram criados.
- `description:` Fornece uma descrição do output, neste caso, "Região do GCloud".
---

#### ID do Projeto GCP

output "project_id" {
  value       = var.project_id
  description = "ID do projeto GCP"
  sensitive   = true
}

- `value:` Exibe o valor da variável var.project_id, que contém o ID do projeto Google Cloud.
- `description:` Fornece uma descrição do output, neste caso, "ID do projeto GCP".
- `sensitive:` Marca este output como sensível, escondendo seu valor em logs e saídas do Terraform
---

### Nome do Cluster GKE

output "kubernetes_cluster_name" {
  value       = google_container_cluster.magalu_cluster.name
  description = "Nome do cluster GKE"
  sensitive   = true
}

- `value:`  Exibe o nome do cluster GKE criado, acessando o recurso google_container_cluster.magalu_cluster.name.
- `description:`  Fornece uma descrição do output, neste caso, "Nome do cluster GKE".
- `sensitive:` Marca este output como sensível, escondendo seu valor em logs e saídas do Terraform.
---

### Host do Cluster GKE

output "kubernetes_cluster_host" {
  value       = google_container_cluster.magalu_cluster.endpoint
  description = "Host do cluster GKE"
  sensitive   = true
}

- `value:` Exibe o endpoint (host) do cluster GKE criado, acessando o recurso google_container_cluster.magalu_cluster.endpoint.
- `description:` Fornece uma descrição do output, neste caso, "Host do cluster GKE".
- `sensitive:` Marca este output como sensível, escondendo seu valor em logs e saídas do Terraform.

### Definição de Variáveis do Terraform

Este código define três variáveis para uso em configurações do Terraform.

#### Variável (`variables.tf`)

variable "gke_num_nodes" {
  default     = 1
  description = "numero de nodes para o cluster"
}

- `default:` Define o valor padrão como 1.
- `description:` Fornece uma descrição para a variável, neste caso, "número de nodes para o cluster".

## Variável project_id

variable "project_id" {
  description = "project id"
  default = "magalu-challenge"
}

- `default:` Define o valor padrão como "magalu-challenge".
- `description:` Fornece uma descrição para a variável, neste caso, "project id".

## Variável region

variable "region" {
  description = "region"
  default = "us-central1"
}

- `default:` Define o valor padrão como "us-central1".
- `description:` Fornece uma descrição para a variável, neste caso, "region".
---

## Em resumo...

- `main.tf`: Especifica que o Terraform deve utilizar a versão 5.35.0 do provedor Google Cloud, fornecido pela HashiCorp.

- `gke.tf`: Provisiona um cluster GKE com um node pool gerenciado separadamente, detalhando cada configuração e uso de funções específicas como `sensitive()`.

- `vpc.tf`: Configura o provedor Google Cloud com o ID do projeto e a região especificados, cria uma rede VPC sem sub-redes automáticas e, em seguida, cria uma sub-rede manualmente dentro dessa VPC com um intervalo de endereços IP especificado.

- `outputs.tf`: No Terraform é utilizado para exibir informações importantes sobre a infraestrutura provisionada, como a região do Google Cloud, o ID do projeto, o nome do cluster GKE e o endpoint do cluster GKE.

- `variables.tf`: São utilizadas para configurar o número de nós em um cluster GKE, o ID do projeto e a região no Google Cloud.

