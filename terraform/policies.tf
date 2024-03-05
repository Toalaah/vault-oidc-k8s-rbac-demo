resource "vault_policy" "god" {
  name = "god"

  policy = <<EOT
path "*" {
  capabilities = ["create", "update", "read", "delete", "list"]
}
EOT
}
