resource "vault_identity_oidc_scope" "my-scope" {
  name     = "my-scope"
  template = <<EOF
    {
      "groups": {{identity.entity.groups.names}},
      "alias": {{identity.entity.name}}
    }
    EOF

  description = "Groups scope."
}

resource "vault_identity_oidc_provider" "k8s-oidc-provider" {
  # must match oidc-issuer-url in ../cluster.yml
  name          = "k8s-oidc-provider"
  https_enabled = true
  issuer_host   = "vault.local"
  allowed_client_ids = [
    vault_identity_oidc_client.my-client.client_id
  ]
  scopes_supported = [
    vault_identity_oidc_scope.my-scope.name
  ]
}

resource "vault_identity_oidc_key" "my-client-key" {
  name               = "my-client-key"
  allowed_client_ids = ["*"]
  rotation_period    = 3600
  verification_ttl   = 3600
}

resource "vault_identity_oidc_client" "my-client" {
  name = "my-client"
  key  = vault_identity_oidc_key.my-client-key.name
  redirect_uris = [
    # kube-oidc-login defaults to this redirect uri
    "http://localhost:8000",
    "http://127.0.0.1:8000"
  ]
  assignments = [
    vault_identity_oidc_assignment.my-assignment.name
  ]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_identity_oidc_role" "my-role" {
  name = "my-role"
  key  = vault_identity_oidc_key.my-client-key.name
  ttl  = 3600
}

resource "vault_identity_oidc_assignment" "my-assignment" {
  name       = "my-assignment"
  entity_ids = [vault_identity_entity.admin.id]
  group_ids  = [vault_identity_group.my-group.id]
}

output "client-id" {
  value = vault_identity_oidc_client.my-client.client_id
}
