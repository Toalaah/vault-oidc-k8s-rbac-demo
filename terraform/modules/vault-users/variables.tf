variable "users" {

  description = <<EOT
A list of objects representing a composite vault user entity, defining a role
and login.

The `alias` property is used to have a proper handle for each distinct entity.
It must be unique.

The `policies` property contains a map that defines how a specific vault policy
gets applied to the session.

The `password` property is the initial login password of a user. The password
can be self rotated via the policy `change-pw`. Changes in this property do not
cause a state change for terraforms livecycle.

The `metadata` property hold arbitrary map of data, that we can use for auditing
purposes e.g.

Validations are done for password format and user alias uniqueness.

Concerned resources:
 - [vault_generic_endpoint](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_endpoint)
 - [vault_identity_entity](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity)
 - [vault_identity_entity_policies](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity_policies)
 - [vault_identity_entity_alias](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity_alias)
 - [vault_identity_group](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group)
EOT

  type = list(object({
    alias = string
    identity = object({
      external_policies = bool
      exclusive         = bool
    })
    policies = object({
      from_auth   = list(string)
      from_entity = list(string)
      from_groups = list(string)
    })
    metadata = map(string)
  }))

  //validation {
  //  condition = contains(
  //    [for u in var.users : length(u.password) > 16], true
  //  )
  //  error_message = "The initial password must be longer than 16."
  //}

  //validation {
  //  condition = contains(
  //    [for u in var.users :
  //    can(regex("^.*", u.password))],
  //  true)
  //  error_message = "Initial password for user must be special."
  //}

  validation {
    condition     = length(compact([for u in var.users : u.alias])) == length(var.users)
    error_message = "All user aliases must be unique. Tf wont show this validation."
  }

  default = [
    {
      alias = "test-user"
      identity = {
        external_policies = true
        exclusive         = false
      }
      policies = {
        from_auth   = ["change-pw"]
        from_entity = ["personal"]
        from_groups = ["users", "operators"]
      }
      otc = {
        groups = []
        roles  = []
      }
      metadata = {
        FullName = "Max Musterman"
        Role     = "operator"
        Email    = "ops@company.tld"
      }
    },
  ]
}

variable "groups" {
  description = <<EOT
A list of objects representing a vault user group, defining a role
and permissions.

Concerned resources:
 - [vault_identity_group](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group)
EOT
  type = list(object({
    type     = string
    policies = list(string)
    name     = string
    metadata = map(string)
  }))
  validation {
    condition     = length(compact([for g in var.groups : g.name])) == length(var.groups)
    error_message = "All group names must be unique. Tf wont show this validation."
  }
  default = [
    {
      name     = "operators"
      type     = "internal"
      policies = ["operator"]
      metadata = {
        version = "1"
        name    = "operators"
      }
    },
    {
      name     = "users"
      type     = "internal"
      policies = ["user"]
      metadata = {
        version = "1"
        name    = "users"
      }
    }
  ]
}

variable "kv_secret_backend" {
  type = object({
    path        = string
    type        = string
    description = string
    # options     = set(object({}))
  })
}
