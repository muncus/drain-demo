data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.cluster-a.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.cluster-a.ca_certificate)
  alias                  = "cluster-A"
  ignore_annotations = [
    "cloud\\.google\\.com\\/neg",
    "cloud\\.google\\.com\\/neg-status",
    "^autopilot\\.gke\\.io\\/.*",
  ]
}

provider "kubernetes" {
  host                   = "https://${module.cluster-b.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.cluster-b.ca_certificate)
  alias                  = "cluster-B"
  ignore_annotations = [
    "cloud\\.google\\.com\\/neg",
    "cloud\\.google\\.com\\/neg-status",
    "^autopilot\\.gke\\.io\\/.*",
  ]
}

module "cluster-a" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"
  version = "~> 30.0"

  project_id                      = var.project
  name                            = "${var.cluster_name}-a"
  regional                        = true
  region                          = var.region
  zones                           = [var.zones[0]]
  network                         = module.network-shared.network_name
  subnetwork                      = "${var.cluster_name}-network-a-subnet"
  ip_range_pods                   = "ip-range-pods"
  ip_range_services               = "ip-range-svcs"
  release_channel                 = "REGULAR"
  enable_vertical_pod_autoscaling = true
  deletion_protection             = false
  depends_on                      = [module.network-shared]
}

module "network-shared" {
  source  = "terraform-google-modules/network/google"
  version = ">= 7.5"

  project_id   = var.project
  network_name = "${var.cluster_name}-network-shared"

  subnets = [
    {
      subnet_name   = "${var.cluster_name}-network-a-subnet"
      subnet_ip     = "10.10.0.0/17"
      subnet_region = var.region
    },
    {
      subnet_name   = "${var.cluster_name}-network-a-master-subnet"
      subnet_ip     = "10.20.0.0/17"
      subnet_region = var.region
    },
    {
      subnet_name   = "${var.cluster_name}-network-b-subnet"
      subnet_ip     = "10.50.0.0/17"
      subnet_region = var.region
    },
    {
      subnet_name   = "${var.cluster_name}-network-b-master-subnet"
      subnet_ip     = "10.60.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${var.cluster_name}-network-a-subnet" = [
      {
        range_name    = "ip-range-pods"
        ip_cidr_range = "192.168.0.0/24"
      },
      {
        range_name    = "ip-range-svcs"
        ip_cidr_range = "192.168.10.0/24"
      },
    ]
    "${var.cluster_name}-network-b-subnet" = [
      {
        range_name    = "ip-range-pods"
        ip_cidr_range = "192.168.20.0/24"
      },
      {
        range_name    = "ip-range-svcs"
        ip_cidr_range = "192.168.30.0/24"
      },
    ]
  }
}

module "cluster-b" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"
  version = "~> 30.0"

  project_id                      = var.project
  name                            = "${var.cluster_name}-b"
  regional                        = true
  region                          = var.region
  zones                           = [var.zones[1]]
  network                         = module.network-shared.network_name
  subnetwork                      = "${var.cluster_name}-network-b-subnet"
  ip_range_pods                   = "ip-range-pods"
  ip_range_services               = "ip-range-svcs"
  release_channel                 = "REGULAR"
  enable_vertical_pod_autoscaling = true
  deletion_protection             = false
  depends_on                      = [module.network-shared]
}