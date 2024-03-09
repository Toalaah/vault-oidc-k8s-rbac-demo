output "oidc_roles" {
  value = { for role_name, role in local.oidc_role_map :
    role_name => merge(
      { role = vault_identity_oidc_role.roles[role_name] },
      { policy = vault_policy.oidc_role_reader_policies[role_name] }
    )
  }
  description = <<-EOF
  EOF
}
