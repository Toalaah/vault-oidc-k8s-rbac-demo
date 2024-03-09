#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
source $(pwd)/lib.sh

usage() { echo "Usage: $0 -c client_id [-f]"; }

force_restart=""
client_id=""
while getopts ":c:f" option; do
  case $option in
    c)
      client_id="$OPTARG"
      ;;
    f)
      force_restart="yes"
      ;;
  esac
done

if [[ "$client_id" = "" ]]; then
  usage
  exit 1
fi

if kind get clusters 2>/dev/null | grep -q '^kind$'; then
  if [[ "$force_restart" = "yes" ]]; then
    log "Force-restarting cluster..."
    kind delete cluster
  else
    log "Cluster already running..."
    exit 0
  fi
fi

log "Starting up kind cluster..."
config=$(sed "s/changeme/$client_id/" ../cluster.yml)
kind create cluster --kubeconfig=./KUBECONFIG --config=- <<< $config
# trust mounted mkCert root certificate
log "Adding mkCert root cert to trust store..."
docker exec -d kind-control-plane update-ca-certificates

if ! docker network inspect kind | grep -q vault; then
  log "Linking vault container to cluster network..."
  docker network connect --alias $VAULT_DOMAIN kind vault
fi
