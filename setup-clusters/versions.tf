terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.26.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "5.16.0"
    }
  }
}