resource "vault_identity_oidc_key" "key" {
  name      = var.key_opts.name
  algorithm = var.key_opts.algorithm
}

resource "vault_identity_oidc_key_allowed_client_id" "oidc_key_role" {
  key_name          = vault_identity_oidc_key.key.name
  allowed_client_id = var.client_id
}

resource "vault_identity_oidc_role" "roles" {
  for_each = local.oidc_role_map

  name      = each.value.formatted_name
  client_id = var.client_id
  key       = vault_identity_oidc_key.key.name
  template  = <<-EOF
    {
      "alias": {{identity.entity.name}},
      "nbf": {{time.now}},
      "groups": ${jsonencode(each.value.associated_cluster_roles)},
      "role": "${each.key}"
    }
  EOF
}

resource "vault_policy" "oidc_role_reader_policies" {
  for_each = local.oidc_role_map

  name   = each.value.formatted_name
  policy = <<-EOF
    path "identity/oidc/token/${each.value.formatted_name}" {
      capabilities = ["read"]
    }
  EOF
}

locals {
  oidc_role_map = {
    for r in var.oidc_roles : r.name =>
    merge(
      r,
      { formatted_name = format(var.vault_policy_format_string, r.name) }
    )
  }
}
