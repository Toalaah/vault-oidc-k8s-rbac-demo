# vault-oidc-k8s-rbac demo

## Steps

1. Bootstrap the vault server and export credentials. Note that this will
   modify your `/etc/hosts` file, so you may need to provide su credentials.

    ```bash
    $ make vault
    # ...
    [+] Waiting for root token...

    You can now interact with the vault server by running:

    export VAULT_TOKEN=hvs.nNafxvEvDFAn6Ym6XdkI8yky
    export VAULT_ADDR=https://vault.local:443

    $ export VAULT_TOKEN=hvs.nNafxvEvDFAn6Ym6XdkI8yky
    $ export VAULT_ADDR=https://vault.local:443
    ```

2. Bootstrap the kind cluster and export credentials.

    ```bash
    $ make cluster
    # ...
    $ export KUBECONFIG=$(pwd)/KUBECONFIG
    $ export KUBE_CONFIG_PATH=$KUBECONFIG
    ```

3. Apply terraform infrastructure. This will create some sample vault users
   `bob` and `alice` in addition to `vault <=> k8s` RBAC mappings allowing
   entities with certain policies to generate themselves JWTs which in turn
   grant privileges reflecting the mapped cluster role of the policy.

    ```bash
    $ make terraform
    ```

4. We will now modify our kubeconfig with two new users `viewer` and
   `operator`. These will bind to the `cluster-viewer-dev` and
   `cluster-operator-dev` OIDC role endpoints respectively. Note that these
   users are *independent* of the vault users and merely reflect different
   privilege levels that the "real" user (in this case bob or alice) wishes to
   use at that current point in time. As such, even "superusers" such as alice
   may choose to default to a low-privilege user in their kubeconfig in order
   to mitigate accidental damage to the cluster.

    ```bash
    $ make kube-user USER=operator ROLE=cluster-operator-dev
    # ...
    user "operator" set.
    $ make kube-user USER=viewer ROLE=cluster-viewer-dev
    # ...
    user "viewer" set.
    ```

5. Attempt to list namespaces as both the bob and alice users. As both inherit
   the `cluster-viewer-dev` policy, they are able to issue themselves JWTs with
   a `group` claim containing the `read_only` group. This maps to the
   `vault:read_only` ClusterRole via the previously generated
   ClusterRoleBindings.

    ```bash
    $ VAULT_TOKEN=$(vault login -token-only -method=userpass -path=pw username=alice password=password) \
        kubectl --user=viewer get ns
    NAME                 STATUS   AGE
    default              Active   67m
    kube-node-lease      Active   67m
    kube-public          Active   67m
    kube-system          Active   67m
    local-path-storage   Active   67m

    $ VAULT_TOKEN=$(vault login -token-only -method=userpass -path=pw username=bob password=password) \
        kubectl --user=viewer get ns
    # ...
    ```

6. As *only* alice inherits the `cluster-operator-dev` policy, she is able to
   issue herself "upgraded" JWTs by hitting the operator endpoint which give
   her the ability to create namespaces whereas bob is not. Bob is only able to
   use the "viewer" kubectl user and as such cannot manipulate namespaces.

    ```bash
    $ VAULT_TOKEN=$(vault login -token-only -method=userpass -path=pw username=bob password=password) \
        kubectl --user=viewer create ns test
    Error from server (Forbidden): namespaces is forbidden: User "vault:bob" cannot create resource "namespaces" in AP
    $ # Bob tries to elevate to a more privileged token by using the `operator` endpoint, but is missing the required vault-side policies to do so.
    $ VAULT_TOKEN=$(vault login -token-only -method=userpass -path=pw username=bob password=password) \
        kubectl --user=operator create ns test
    Error reading identity/oidc/token/cluster-operator-dev: Error making API request.

    URL: GET https://vault.local/v1/identity/oidc/token/cluster-operator-dev
    Code: 403. Errors:

    * 1 error occurred:
        * permission denied


    Unable to connect to the server: getting credentials: exec: executable bash failed with exit code 2
    $ # Meanwhile, alice is able to call the operator endpoint and obtain a token giving her the `vault:operator` ClusterRole, enabling her to create the namespace.
    $ VAULT_TOKEN=$(vault login -token-only -method=userpass -path=pw username=alice password=password) \
        kubectl --user=operator create ns test
    namespace/test created
    ```

## Acknowledgments and Miscellaneous Notes

- The [`vault-users`](./terraform/modules/vault-users) terraform module was
  originally written by https://github.com/krysopath and was only mildly
  adapted for this demo, all credit goes to him.

- In a sense one would not be wrong to claim that this is not "real" OIDC
  integration with vault as there is no standard authorization flow or similar
  process happening. That being said, the tokens are issued in such a way that
  they are OIDC compliant, and once issued can be used and verified as a
  standard ID token.

  Of course, vault can be used as a "real" OIDC IdP, however the configuration
  options especially related to access control are somewhat limited in this
  case. Some problems that I encountered while attempting to configure a
  similar setup using vault's OIDC provider:

    - The scope/JSON templating is quite limited. One can pretty much only
      return *all* the entity's groups. This is a problem when you want to
      configure multiple tenants/clusters which use the *same* kubernetes-side
      role names as a group (e.g `cluster-operator`) would imply operator
      privileges on all clusters (e.g dev, prod). There is no way, using an
      entity's groups as a source of privilege, to *only* return
      `cluster-operator` in the groups claim when using a dev-tenant client,
      and at the same time omit it when using a prod-client. This makes strict
      access control a pain. Furthermore, mapping entity's actual groups to
      clusterroles becomes difficult when you want to retain the ability for
      higher-privileged user's to issue themselves tokens that are less
      privileged without hard-coding custom scopes, which quickly becomes
      unmanageable as your groups/desired privilege levels increase in number.
      This issue of filtered groups or a notion of "roles" is also brought up
      in this [issue](https://github.com/hashicorp/vault/issues/14986), which
      discusses many of the same drawbacks of using vault's OIDC provider for
      such a use-case.

    - Scopes cannot be access controlled. If this were the case one could allow
      only authorized users to request certain scopes, and in turn distinct
      claims which could be used as a source of RBAC controls on the cluster
      side. Hence the pain-points brought up above would be resolved.
