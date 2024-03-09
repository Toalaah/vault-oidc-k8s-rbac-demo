#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
source $(pwd)/lib.sh
cd ../

CERT_DIR=$(pwd)/vault/certs

# idempotent install of root ca
mkcert -install >/dev/null 2>&1

if ! test -f $CERT_DIR/$VAULT_DOMAIN.crt; then
  log "Creating certificate for domain '$VAULT_DOMAIN'"
  mkcert -cert-file $CERT_DIR/$VAULT_DOMAIN.crt -key-file $CERT_DIR/$VAULT_DOMAIN.key $VAULT_DOMAIN
  cp $(mkcert -CAROOT)/rootCA.pem .
else
  log "Certificate for domain '$VAULT_DOMAIN' already exists"
fi
