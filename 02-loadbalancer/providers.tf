data "google_client_config" "default" {}

data "google_container_cluster" "cluster-A" {
    name = "${var.cluster_name}-a"
    location = var.region
}
data "google_container_cluster" "cluster-B" {
    name = "${var.cluster_name}-b"
    location = var.region
}

provider "google" {
  project = var.project
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.cluster-A.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster-A.master_auth.0.cluster_ca_certificate)
  alias                  = "cluster-A"
  ignore_annotations = [
    "cloud\\.google\\.com\\/neg",
    "cloud\\.google\\.com\\/neg-status",
    "^autopilot\\.gke\\.io\\/.*",
  ]
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.cluster-B.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster-B.master_auth.0.cluster_ca_certificate)
  alias                  = "cluster-B"
  ignore_annotations = [
    "cloud\\.google\\.com\\/neg",
    "cloud\\.google\\.com\\/neg-status",
    "^autopilot\\.gke\\.io\\/.*",
  ]
}