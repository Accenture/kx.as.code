output "ssh_key" {
  value     = tls_private_key.kx_key.private_key_pem
  sensitive = true
}
