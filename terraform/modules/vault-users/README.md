## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | ~> 3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vault_auth_backend.password_auth_method](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/auth_backend) | resource |
| [vault_generic_endpoint.user_pw_login](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_endpoint) | resource |
| [vault_identity_entity.user_entity](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity) | resource |
| [vault_identity_entity_alias.user_alias](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity_alias) | resource |
| [vault_identity_entity_policies.user_policies](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity_policies) | resource |
| [vault_identity_group.vault_groups](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group) | resource |
| [vault_policy.change_pw](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.kv_lister](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.kv_reader](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.kv_writer](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.operator](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.personal](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy_document.change_pw](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |
| [vault_policy_document.kv_lister](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |
| [vault_policy_document.kv_reader](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |
| [vault_policy_document.kv_writer](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |
| [vault_policy_document.operator](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |
| [vault_policy_document.personal](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_groups"></a> [groups](#input\_groups) | A list of objects representing a vault user group, defining a role<br>and permissions.<br><br>Concerned resources:<br> - [vault\_identity\_group](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group) | <pre>list(object({<br>    type     = string<br>    policies = list(string)<br>    name     = string<br>    metadata = map(string)<br>  }))</pre> | <pre>[<br>  {<br>    "metadata": {<br>      "name": "operators",<br>      "version": "1"<br>    },<br>    "name": "operators",<br>    "policies": [<br>      "operator"<br>    ],<br>    "type": "internal"<br>  },<br>  {<br>    "metadata": {<br>      "name": "users",<br>      "version": "1"<br>    },<br>    "name": "users",<br>    "policies": [<br>      "user"<br>    ],<br>    "type": "internal"<br>  }<br>]</pre> | no |
| <a name="input_kv_secret_backend"></a> [kv\_secret\_backend](#input\_kv\_secret\_backend) | n/a | <pre>object({<br>    path        = string<br>    type        = string<br>    description = string<br>    # options     = set(object({}))<br>  })</pre> | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | A list of objects representing a composite vault user entity, defining a role<br>and login.<br><br>The `alias` property is used to have a proper handle for each distinct entity.<br>It must be unique.<br><br>The `policies` property contains a map that defines how a specific vault policy<br>gets applied to the session.<br><br>The `password` property is the initial login password of a user. The password<br>can be self rotated via the policy `change-pw`. Changes in this property do not<br>cause a state change for terraforms livecycle.<br><br>The `metadata` property hold arbitrary map of data, that we can use for auditing<br>purposes e.g.<br><br>Validations are done for password format and user alias uniqueness.<br><br>Concerned resources:<br> - [vault\_generic\_endpoint](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_endpoint)<br> - [vault\_identity\_entity](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity)<br> - [vault\_identity\_entity\_policies](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity\_policies)<br> - [vault\_identity\_entity\_alias](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity\_alias)<br> - [vault\_identity\_group](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group) | <pre>list(object({<br>    alias = string<br>    identity = object({<br>      external_policies = bool<br>      exclusive         = bool<br>    })<br>    policies = object({<br>      from_auth   = list(string)<br>      from_entity = list(string)<br>      from_groups = list(string)<br>    })<br>    metadata = map(string)<br>  }))</pre> | <pre>[<br>  {<br>    "alias": "test-user",<br>    "identity": {<br>      "exclusive": false,<br>      "external_policies": true<br>    },<br>    "metadata": {<br>      "Email": "ops@company.tld",<br>      "FullName": "Max Musterman",<br>      "Role": "operator"<br>    },<br>    "otc": {<br>      "groups": [],<br>      "roles": []<br>    },<br>    "policies": {<br>      "from_auth": [<br>        "change-pw"<br>      ],<br>      "from_entity": [<br>        "personal"<br>      ],<br>      "from_groups": [<br>        "users",<br>        "operators"<br>      ]<br>    }<br>  }<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_created_users"></a> [created\_users](#output\_created\_users) | n/a |
| <a name="output_vault_groups"></a> [vault\_groups](#output\_vault\_groups) | n/a |
