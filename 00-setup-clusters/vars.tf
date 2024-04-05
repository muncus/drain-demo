variable "project" {
  type = string
  description = "project id in which to create resources"
}

variable "cluster_name" {
  type    = string
  default = "drain-demo-1"
  description = "used as a name prefix on created resources"
}

variable "region" {
  type    = string
  default = "us-east1"
  description = "regional resources are created here (e.g. networks)"
}

variable "zones" {
  type    = list(string)
  default = ["us-east1-c", "us-east1-b"]
  description = "zones in which to create nodes. used for clusters A and B"
}

