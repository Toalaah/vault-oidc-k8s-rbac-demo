# This should only be needed if the `api_addr` config value is not set. If
# controls the `iss` scope of ID tokens returned by the `identity/oidc/{role}`
# route.
resource "vault_identity_oidc" "oid_config" {
  issuer = "https://vault.local"
}

module "kubernetes_oidc_role_binding" {
  source = "../modules/vault-oidc-k8s-rbac"

  key_opts = {
    name = "k8s-dev-cluster"
  }
  client_id                  = "kind"
  cluster_role_prefix        = "vault:"
  vault_policy_format_string = "%s-dev"

  oidc_roles = [
    {
      name                     = "cluster-viewer"
      associated_cluster_roles = ["read_only"]
    },
    {
      name                     = "cluster-operator"
      associated_cluster_roles = ["operator", "read_only"]
    }
  ]

  cluster_roles = [
    {
      name = "operator"
      rules = [
        {
          api_groups = ["*"]
          resources  = ["*"]
          verbs      = ["*"]
        },
        {
          non_resource_urls = ["*"]
          verbs             = ["*"]
        }
      ]
    },
    {
      name = "read_only"
      rules = [
        {
          api_groups = [""]
          resources  = ["namespaces", "pods"]
          verbs      = ["get", "list", "watch"]
        }
      ]
    }
  ]
}
