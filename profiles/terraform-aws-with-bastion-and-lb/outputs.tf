output "ssh_key" {
  value     = tls_private_key.kx_key.private_key_pem
  sensitive = true
}

output "ssh_key_public_pem" {
  value     = tls_private_key.kx_key.public_key_pem
  sensitive = true
}

output "ssh_key_public_openssh" {
  value     = tls_private_key.kx_key.public_key_openssh
  sensitive = true
}

output "kx_bastion_public_ip" {
  value = aws_instance.kx_bastion.public_ip
}

output "kx_main_admin_private_ip" {
  value = aws_instance.kx_main_admin.private_ip
}

output "kx_main_replica_nodes_private_ip" {
  value = aws_instance.kx_main_replica.*.private_ip
}

output "kx_worker_private_ip" {
  value = aws_instance.kx_worker.*.private_ip
}

output "lb_public_subnets" {
  value = local.lb_public_subnets
}
