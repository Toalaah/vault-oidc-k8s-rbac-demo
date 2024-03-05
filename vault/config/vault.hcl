ui = true

disable_clustering = true

storage "file" {
  path = "/vault/file"
}

listener "tcp" {
  address       = "127.0.0.1:8200"
  tls_disable  = true
}

listener "tcp" {
  address       = "0.0.0.0:443"
  tls_disable  = false
  tls_cert_file = "/mnt/certs/vault.local.crt"
  tls_key_file  = "/mnt/certs/vault.local.key"
}
