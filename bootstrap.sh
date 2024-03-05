#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

log() {
  echo -e "\033[0;1;36m[+]\033[0m $@"
}


CERT_DIR=$(pwd)/vault/certs
VAULT_DOMAIN=vault.local

# idempotent install of root ca
mkcert -install >/dev/null 2>&1

if ! test -f $CERT_DIR/$VAULT_DOMAIN.crt; then
  log "Creating certificate for domain '$VAULT_DOMAIN'"
  mkcert -cert-file $CERT_DIR/$VAULT_DOMAIN.crt -key-file $CERT_DIR/$VAULT_DOMAIN.key $VAULT_DOMAIN
  cp $(mkcert -CAROOT)/rootCA.pem .
fi

log "Starting up containers..."
docker-compose up -d --quiet-pull

tpl_str="127.0.0.1\t$VAULT_DOMAIN"
if ! grep -q -P "$tpl_str" /etc/hosts; then
  log "Appending $VAULT_DOMAIN to /etc/hosts..."
  printf "$tpl_str\n" | sudo tee -a /etc/hosts >/dev/null
  # https://superuser.com/questions/1596225/dns-resolution-delay-for-entries-in-etc-hosts
  if [[ "$(uname -s)" = "Darwin" ]]; then
    tpl_str="::1\t\t$VAULT_DOMAIN"
    if ! grep -q -P "$tpl_str" /etc/hosts; then
      printf "$tpl_str\n" | sudo tee -a /etc/hosts >/dev/null
    fi
    sudo killall -HUP mDNSResponder
  fi
fi


log "Waiting for root token..."
root_token=""
while [ -z "$root_token" ]; do
  sleep 1
  root_token=$(docker-compose logs --no-log-prefix unseal-sidecar | grep '^Root token' | tail -n1 | cut -d' ' -f3)
done

if kind get clusters 2>/dev/null | grep -q '^kind$'; then
  log "Cluster already running..."
else
  log "Starting up kind cluster..."
  kind create cluster --kubeconfig=$(pwd)/KUBECONFIG --config=./cluster.yml
  # trust mounted mkCert certificate
  docker exec kind-control-plane update-ca-certificates
fi

log "Linking vault container to cluster network..."
docker network connect --alias $VAULT_DOMAIN kind vault


cat << MSG

You can now interact with the vault server by running:

export VAULT_TOKEN=$root_token
export VAULT_ADDR=https://$VAULT_DOMAIN:443
MSG
