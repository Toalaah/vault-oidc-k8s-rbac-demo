#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
source $(pwd)/lib.sh

log "Starting up containers..."
docker-compose up -d --quiet-pull

read -r -d '' tpl_str <<EOF
# BEGIN VAULT-OIDC-MANAGED
127.0.0.1    $VAULT_DOMAIN
$([[ "$(uname -s)" = "Darwin" ]] && echo "::1          $VAULT_DOMAIN")
# END VAULT-OIDC-MANAGED
EOF

if ! grep -q -P "^# BEGIN VAULT-OIDC-MANAGED$" /etc/hosts; then
  log "Appending $VAULT_DOMAIN to /etc/hosts..."
  printf "$tpl_str\n" | sudo tee -a /etc/hosts >/dev/null
  # https://superuser.com/questions/1596225/dns-resolution-delay-for-entries-in-etc-hosts
  [[ "$(uname -s)" = "Darwin" ]] && sudo killall -HUP mDNSResponder
fi


log "Waiting for root token..."
root_token=""
while [ -z "$root_token" ]; do
  sleep 1
  root_token=$(docker-compose logs --no-log-prefix unseal-sidecar | grep '^Root token' | tail -n1 | cut -d' ' -f3)
done


cat <<MSG

You can now interact with the vault server by running:

export VAULT_TOKEN=$root_token
export VAULT_ADDR=https://$VAULT_DOMAIN:443
MSG
