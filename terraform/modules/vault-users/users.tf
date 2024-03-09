locals {
  users = { for u in var.users : u.alias => u }
}

resource "vault_auth_backend" "password_auth_method" {
  type = "userpass"
  path = "pw"
  tune {
    max_lease_ttl      = "86400s"
    listing_visibility = "unauth"
  }
}

resource "vault_generic_endpoint" "user_pw_login" {
  for_each             = local.users
  ignore_absent_fields = true
  path                 = "auth/${vault_auth_backend.password_auth_method.path}/users/${each.key}"

  lifecycle {
    ignore_changes = [
      data_json
    ]
  }

  data_json = <<EOT
{
  "policies": [${join(", ", formatlist("\"%s\"", each.value.policies.from_auth))}],
  "password": "password"
}
EOT
}

resource "vault_identity_entity" "user_entity" {
  for_each          = local.users
  name              = each.key
  external_policies = each.value.identity.external_policies
  metadata          = each.value.metadata
}

resource "vault_identity_entity_policies" "user_policies" {
  for_each   = local.users
  depends_on = [vault_identity_entity.user_entity]
  policies   = each.value.policies.from_entity
  exclusive  = each.value.identity.exclusive
  entity_id  = vault_identity_entity.user_entity[each.key].id
}

resource "vault_identity_entity_alias" "user_alias" {
  for_each       = local.users
  name           = each.key
  mount_accessor = vault_auth_backend.password_auth_method.accessor
  canonical_id   = vault_identity_entity.user_entity[each.key].id
}

locals {
  created_users = { for k in keys(local.users) : k => {
    entity_id : vault_identity_entity.user_entity[k].id
    policies : vault_identity_entity.user_entity[k].policies
    metadata : local.users[k].metadata
  } }
}

output "created_users" {
  depends_on = [vault_identity_entity_alias.user_alias]
  value      = local.created_users
}
