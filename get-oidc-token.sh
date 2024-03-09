#!/usr/bin/env bash

set -euo pipefail

role=$1
token=$(vault read -field=token identity/oidc/token/"$role")
payload=$(jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$token")
exp=$(date -d@"$(jq .exp <<< "$payload")" +%FT%TZ)

cat <<TOKEN
{
  "kind": "ExecCredential",
  "apiVersion": "client.authentication.k8s.io/v1beta1",
  "spec": {},
  "status": {
    "expirationTimestamp": "$exp",
    "token": "$token"
  }
}
TOKEN
