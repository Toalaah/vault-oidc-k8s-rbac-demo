resource "vault_identity_entity" "admin" {
  name      = "admin"
  policies  = ["default", vault_policy.god.name ]
  metadata  = {
    name = "Bob Smith"
  }
}

resource "vault_auth_backend" "userpass" {
  path = "userpass"
  type = "userpass"
  description = "userpass"
}

resource "vault_identity_entity_alias" "admin" {
  name            = "bob_smith"
  mount_accessor  = vault_auth_backend.userpass.accessor
  canonical_id    = vault_identity_entity.admin.id
}
