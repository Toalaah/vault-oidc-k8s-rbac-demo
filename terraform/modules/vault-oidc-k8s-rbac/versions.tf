terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3"
    }
  }
}
