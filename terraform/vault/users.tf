module "vault_users" {
  source            = "../modules/vault-users"
  kv_secret_backend = vault_mount.kv
  users = [
    {
      alias = "bob"
      identity = {
        external_policies = true
        exclusive         = false
      }
      metadata = {}
      policies = {
        from_auth = ["change-pw"]
        from_entity = [
          "personal",
          module.kubernetes_oidc_role_binding.oidc_roles["cluster-viewer"].policy.name,
        ]
        from_groups = []
      }
    },
    {
      alias = "alice"
      identity = {
        external_policies = true
        exclusive         = false
      }
      metadata = {}
      policies = {
        from_auth = ["change-pw"]
        from_entity = [
          "personal",
          "developer",
          "operator"
        ]
        from_groups = [
          "cluster-operator-dev"
        ]
      }
    }
  ]
  groups = [
    {
      name = "cluster-operator-dev"
      type = "internal"
      policies = [
        # These are equivalent methods for referencing oidc_roles' associated
        # policies, although the second is perhaps more reusable and less
        # prone to errors over format-string changes, for instance when
        # reusing the module for a new tenant.
        "cluster-viewer-dev",
        module.kubernetes_oidc_role_binding.oidc_roles["cluster-operator"].policy.name,
      ]
      metadata = {
        version = "1"
        name    = "cluster-operator-dev"
      }
    }
  ]
}

resource "vault_mount" "kv" {
  path    = "kv"
  type    = "kv"
  options = { version = 2 }
}
