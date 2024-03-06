resource "vault_identity_entity" "admin" {
  name     = "admin"
  policies = ["default", vault_policy.god.name]
  metadata = {
    name = "Bob Smith"
  }
}

resource "vault_auth_backend" "userpass" {
  path        = "userpass"
  type        = "userpass"
  description = "userpass"
  tune {
    max_lease_ttl      = "86400s"
    listing_visibility = "unauth"
  }
}

resource "vault_identity_entity_alias" "admin" {
  name           = "bob_smith"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.admin.id
}

resource "vault_generic_endpoint" "admin_userpass_login" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/bob_smith"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["default"],
  "password": "passworld123"
}
EOT
}

resource "vault_identity_group" "my-group" {
  name     = "my-group"
  policies = ["default", vault_policy.god.name]

  metadata = {
    version = "2"
  }
}


resource "vault_identity_entity_policies" "user_policies" {
  policies  = ["default", vault_policy.god.name]
  entity_id = vault_identity_entity.admin.id
}
