data "vault_policy_document" "operator" {
  rule {
    path         = "auth/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Manage auth backends  broadly across Vault"
  }
  rule {
    path         = "sys/auth"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "sys/auth/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
  rule {
    path         = "sys/policies/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
  rule {
    path         = "sys/mounts"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
  rule {
    path         = "sys/health"
    capabilities = ["read", "sudo"]
  }
  rule {
    path         = "sys/capabilities"
    capabilities = ["create", "update"]
  }
}

resource "vault_policy" "operator" {
  name   = "operator"
  policy = data.vault_policy_document.operator.hcl
}


data "vault_policy_document" "kv_writer" {
  rule {
    path         = "${var.kv_secret_backend.path}/metadata"
    capabilities = ["list"]
  }
  rule {
    path         = "${var.kv_secret_backend.path}/data/*"
    capabilities = ["read", "list", "create", "update", "delete"]
  }
}

resource "vault_policy" "kv_writer" {
  name   = "kv-writer"
  policy = data.vault_policy_document.kv_writer.hcl
}

data "vault_policy_document" "kv_reader" {
  rule {
    path         = "${var.kv_secret_backend.path}/metadata"
    capabilities = ["list"]
  }
  rule {
    path         = "${var.kv_secret_backend.path}/data/*"
    capabilities = ["read", "list"]
  }
}

resource "vault_policy" "kv_reader" {
  name   = "kv-reader"
  policy = data.vault_policy_document.kv_reader.hcl
}

data "vault_policy_document" "kv_lister" {
  rule {
    path         = "${var.kv_secret_backend.path}/metadata"
    capabilities = ["list"]
  }
  rule {
    path         = "${var.kv_secret_backend.path}/data/*"
    capabilities = ["list"]
  }
}

resource "vault_policy" "kv_lister" {
  name   = "kv-lister"
  policy = data.vault_policy_document.kv_lister.hcl
}

data "vault_policy_document" "personal" {
  rule {
    path         = "${var.kv_secret_backend.path}/data/personal/{{identity.entity.aliases.${vault_auth_backend.password_auth_method.accessor}.name}}/*"
    capabilities = ["create", "read", "update", "delete", "sudo"]
  }

  rule {
    path         = "${var.kv_secret_backend.path}/metadata/personal/{{identity.entity.aliases.${vault_auth_backend.password_auth_method.accessor}.name}}/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${var.kv_secret_backend.path}/metadata/personal/+"
    capabilities = ["list"]
  }

}

resource "vault_policy" "personal" {
  name   = "personal"
  policy = data.vault_policy_document.personal.hcl
}

data "vault_policy_document" "change_pw" {
  rule {
    path         = "auth/${vault_auth_backend.password_auth_method.path}/users/{{identity.entity.aliases.${vault_auth_backend.password_auth_method.accessor}.name}}"
    capabilities = ["update", "read"]
    allowed_parameter {
      key   = "password"
      value = []
    }
  }
}

resource "vault_policy" "change_pw" {
  name   = "change-pw"
  policy = data.vault_policy_document.change_pw.hcl
}
