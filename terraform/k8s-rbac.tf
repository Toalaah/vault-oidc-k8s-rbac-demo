locals {
  prefix = "vault:"
}

resource "kubernetes_cluster_role" "operator" {
  metadata {
    name = "${local.prefix}operator"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role" "developer" {
  metadata {
    name = "${local.prefix}developer"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}
