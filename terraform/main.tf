terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.25.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.26.0"
    }
  }
}

provider "vault" {}
provider "kubernetes" {}
