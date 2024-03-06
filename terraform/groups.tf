resource "vault_identity_group" "operator" {
  name     = "operator"
  policies = ["default", "god"]
}

resource "vault_identity_group_member_entity_ids" "members" {
  member_entity_ids = [vault_identity_entity.admin.id]
  group_id          = vault_identity_group.operator.id
}

