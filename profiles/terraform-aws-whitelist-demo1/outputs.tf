output "ssh_key" {
  value     = tls_private_key.kx_key.private_key_pem
  sensitive = true
}

output "kx_bastion_public_ip" {
  value = aws_instance.kx_bastion.public_ip
}

output "kx_main_private_ip" {
  value = aws_instance.kx_main.private_ip
}

output "kx_worker_private_ip" {
  value = aws_instance.kx_worker.*.private_ip
}