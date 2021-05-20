output "kx-main-floating-address" {
 value = openstack_compute_floatingip_associate_v2.kx-main-floating-ip-associate.*.floating_ip
}

output "kx-worker-floating-address" {
 value = openstack_compute_floatingip_associate_v2.kx-worker-floating-ip-associate.*.floating_ip
}
