variable "project" {
  type = string
}

// used in creation of both zones, with a suffix.
variable "cluster_name" {
  type    = string
  default = "drain-demo-1"
}
// some resources are regional, like networks.
variable "region" {
  type    = string
  default = "us-east1"
}

variable "zones" {
  type    = list(string)
  default = ["us-east1-c", "us-east1-b"]
}

provider "google" {
  project = var.project
}
