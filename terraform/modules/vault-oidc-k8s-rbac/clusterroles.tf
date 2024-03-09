resource "kubernetes_cluster_role" "cluster_roles" {
  for_each = local.cluster_roles_map

  metadata {
    name = each.key
  }

  dynamic "rule" {
    for_each = each.value.rules
    content {
      api_groups        = rule.value.api_groups
      non_resource_urls = rule.value.non_resource_urls
      resource_names    = rule.value.resource_names
      resources         = rule.value.resources
      verbs             = rule.value.verbs
    }
  }
}

resource "kubernetes_cluster_role_binding" "role_bindings" {
  for_each = local.cluster_roles_map

  metadata {
    name = each.key
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_roles[each.key].metadata[0].name
  }

  subject {
    kind = "Group"
    name = each.key
  }
}

locals {
  cluster_roles_map = {
    for r in var.cluster_roles : "${var.cluster_role_prefix}${r.name}" => r
  }
}
