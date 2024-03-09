#!/bin/sh

mkdir -p /vault/operator

if ! test -f /vault/operator/unseal-key; then
  while true; do
    vault status >/dev/null
    if [ $? -eq 2 ]; then
      break
    fi
    sleep 2
    echo "Waiting for status"
  done
  echo "Performing initial vault unseal..."
  sleep 1
  output="$(vault operator init -t 1 -n 1 2>&1)"
  echo "$output" | sed 1qd | cut -d' ' -f4 > /vault/operator/unseal-key
  echo "$output" | sed 3qd | cut -d' ' -f4 > /vault/operator/root-token
fi

if ! vault status >/dev/null; then
  vault operator unseal "$(cat /vault/operator/unseal-key)"
  echo "Completed vault unseal..."
  echo "Root token: $(cat /vault/operator/root-token)"
fi
