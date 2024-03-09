variable "cluster_role_prefix" {
  type        = string
  default     = ""
  description = <<-EOF
    A prefix to attach before ClusterRole and ClusterRoleBinding resources.
    This should match the prefix specified in your kube apiserver's
    `oidc-groups-prefix`. The `oidc-username-prefix` may be free as this
    module's role bindings are based *exclusively* on groups.

    This prefix is *not* appended to the OIDC role on the vault side, only the
    kubernetes resources.

    example:
      cluster_role_prefix = "vault:"
  EOF
}

variable "key_opts" {
  type = object({
    name      = optional(string, "key")
    algorithm = optional(string, "RS256")
  })
  default     = {}
  description = <<-EOF
    Configuration options for the JWT signing key.
  EOF
}

variable "vault_policy_format_string" {
  type        = string
  default     = "%s"
  description = <<-EOF
    The format string of the vault-side created policies enabling access to the
    each respective role endpoint. Must contain *exactly* one '%s' interpreted
    sequence which is replaced by the individual role's `name` variable.

    Entities inheriting this policy receive read access to the
    `identity/oidc/token/{role}` endpoint, allowing the entity to issue
    themselves signed OIDC-compliant tokens for the given role to be used for
    cluster authentication.

    Making the format string distinct, e.g `%s-dev`, allows one to reuse the
    same roles accross multiple tenants in a single vault namespace while
    retaining access control via vault group memberships. For instance, an
    entity may belong to the `reader-dev` and `operator-dev` groups, but only
    the `reader-prod` group.
  EOF
  validation {
    condition     = length(split("%s", var.vault_policy_format_string)) == 2
    error_message = "Format string must contain exactly one `%s` sequence"
  }
}

variable "client_id" {
  type        = string
  description = <<-EOF
    The client id to bind to every role in `roles`. This sets the `iss` claim
    on returned JWTs and is required when you have multiple OIDC roles which
    need to be verified by a single API server.
  EOF
}

variable "oidc_roles" {
  type = list(object({
    name                     = string
    associated_cluster_roles = list(string)
  }))
  default     = []
  description = <<-EOF
    A list of OIDC role endpoints to create. These are acessisible by calling
    the `identity/oidc/token/{role}` endpoint, and return an OIDC-compliant
    token providing a `groups` claim containing the role's associated
    ClusterRole names.

    For each role, a policy is created which may be attached to entities
    enabling them to control access to these endpoints. This policy's name is
    formatted according to `vault_policy_format_string`.
  EOF

  # TODO: maybe validate that associated cluster roles names exist?
}

variable "cluster_roles" {
  type = list(object({
    name = string
    rules = list(object({
      api_groups        = optional(list(string), null)
      non_resource_urls = optional(list(string), null)
      resource_names    = optional(list(string), null)
      resources         = optional(list(string), null)
      verbs             = list(string)
    }))
  }))
  default     = []
  description = <<-EOF
    A list of cluster roles to attach to this role. These are translated to
    ClusterRoles and ClusterRoleBindings.

    Any role from `oidc_roles` referencing a cluster role will result in an
    enpoint capable of returning tokens that provide access as specified by
    this role.
  EOF
}
