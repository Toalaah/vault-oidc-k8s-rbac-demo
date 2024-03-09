locals {
  groups_map = {
    for g in var.groups : g.name => g
  }
}

resource "vault_identity_group" "vault_groups" {
  for_each = local.groups_map
  name     = each.key
  type     = each.value.type
  policies = each.value.policies

  member_entity_ids = compact([
    for u in var.users :
    contains(u.policies.from_groups, each.key)
    ? vault_identity_entity.user_entity[u.alias].id
    : ""
  ])

  metadata = each.value.metadata
}

output "vault_groups" {
  value = vault_identity_group.vault_groups
}
