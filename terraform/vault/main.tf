terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.25.0"
    }
  }
}

provider "vault" {}
