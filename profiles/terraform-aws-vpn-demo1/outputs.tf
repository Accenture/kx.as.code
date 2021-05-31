output "aws_vpc_id" {
  value = aws_vpc.kx-vpc.id
}

output "kx_main_instance_ip_addr" {
  value = aws_instance.kx-main.private_ip
}

output "kx_worker_instance_ip_addr" {
  value = aws_instance.kx-worker.*.private_ip
}

output "vpn_endpoint" {
  value = aws_ec2_client_vpn_endpoint.vpn.dns_name
}
