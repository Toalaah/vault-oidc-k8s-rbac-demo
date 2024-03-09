## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | ~> 3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role.cluster_roles](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.role_bindings](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [vault_identity_oidc_key.key](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_key) | resource |
| [vault_identity_oidc_key_allowed_client_id.oidc_key_role](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_key_allowed_client_id) | resource |
| [vault_identity_oidc_role.roles](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_role) | resource |
| [vault_policy.oidc_role_reader_policies](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | The client id to bind to every role in `roles`. This sets the `iss` claim<br>on returned JWTs and is required when you have multiple OIDC roles which<br>need to be verified by a single API server. | `string` | n/a | yes |
| <a name="input_cluster_role_prefix"></a> [cluster\_role\_prefix](#input\_cluster\_role\_prefix) | A prefix to attach before ClusterRole and ClusterRoleBinding resources.<br>This should match the prefix specified in your kube apiserver's<br>`oidc-groups-prefix`. The `oidc-username-prefix` may be free as this<br>module's role bindings are based *exclusively* on groups.<br><br>This prefix is *not* appended to the OIDC role on the vault side, only the<br>kubernetes resources.<br><br>example:<br>  cluster\_role\_prefix = "vault:" | `string` | `""` | no |
| <a name="input_cluster_roles"></a> [cluster\_roles](#input\_cluster\_roles) | A list of cluster roles to attach to this role. These are translated to<br>ClusterRoles and ClusterRoleBindings.<br><br>Any role from `oidc_roles` referencing a cluster role will result in an<br>enpoint capable of returning tokens that provide access as specified by<br>this role. | <pre>list(object({<br>    name = string<br>    rules = list(object({<br>      api_groups        = optional(list(string), null)<br>      non_resource_urls = optional(list(string), null)<br>      resource_names    = optional(list(string), null)<br>      resources         = optional(list(string), null)<br>      verbs             = list(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_key_opts"></a> [key\_opts](#input\_key\_opts) | Configuration options for the JWT signing key. | <pre>object({<br>    name      = optional(string, "key")<br>    algorithm = optional(string, "RS256")<br>  })</pre> | `{}` | no |
| <a name="input_oidc_roles"></a> [oidc\_roles](#input\_oidc\_roles) | A list of OIDC role endpoints to create. These are acessisible by calling<br>the `identity/oidc/token/{role}` endpoint, and return an OIDC-compliant<br>token providing a `groups` claim containing the role's associated<br>ClusterRole names.<br><br>For each role, a policy is created which may be attached to entities<br>enabling them to control access to these endpoints. This policy's name is<br>formatted according to `vault_policy_format_string`. | <pre>list(object({<br>    name                     = string<br>    associated_cluster_roles = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_vault_policy_format_string"></a> [vault\_policy\_format\_string](#input\_vault\_policy\_format\_string) | The format string of the vault-side created policies enabling access to the<br>each respective role endpoint. Must contain *exactly* one '%s' interpreted<br>sequence which is replaced by the individual role's `name` variable.<br><br>Entities inheriting this policy receive read access to the<br>`identity/oidc/token/{role}` endpoint, allowing the entity to issue<br>themselves signed OIDC-compliant tokens for the given role to be used for<br>cluster authentication.<br><br>Making the format string distinct, e.g `%s-dev`, allows one to reuse the<br>same roles accross multiple tenants in a single vault namespace while<br>retaining access control via vault group memberships. For instance, an<br>entity may belong to the `reader-dev` and `operator-dev` groups, but only<br>the `reader-prod` group. | `string` | `"%s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oidc_roles"></a> [oidc\_roles](#output\_oidc\_roles) | n/a |
