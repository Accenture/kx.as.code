output "config_kx_version" {
 value = local.kx_version
}

output "config_main_node_cpu_cores" {
 value = local.admin_main_node_cpu_cores
}

output "config_main_node_memory" {
 value = local.admin_main_node_memory
}

output "config_worker_node_count" {
 value = local.worker_node_count
}

output "config_worker_node_cpu_cores" {
 value = local.worker_node_cpu_cores
}

output "config_worker_node_memory" {
 value = local.worker_node_memory
}

output "config_num_local_one_gb_volumes" {
 value = local.num_local_one_gb_volumes
}

output "config_num_local_five_gb_volumes" {
 value = local.num_local_five_gb_volumes
}

output "config_num_local_ten_gb_volumes" {
 value = local.num_local_ten_gb_volumes
}

output "config_num_local_thirty_gb_volumes" {
 value = local.num_local_thirty_gb_volumes
}

output "config_num_local_fifty_gb_volumes" {
 value = local.num_local_fifty_gb_volumes
}

output "local_storage_volume_size" {
 value = local.local_storage_volume_size
}

output "glusterfs_storage_volume_size" {
 value = local.glusterfs_storage_volume_size
}

output "kx-main-admin-floating-address" {
 value = openstack_compute_floatingip_associate_v2.kx_main_admin_floating_ip_associate.*.floating_ip
}

output "kx-main-replica-floating-address" {
 value = openstack_compute_floatingip_associate_v2.kx_main_replica_floating_ip_associate.*.floating_ip
}

output "kx-worker-floating-address" {
 value = openstack_compute_floatingip_associate_v2.kx_worker_floating_ip_associate.*.floating_ip
}

output "key_pair_reformatted" {
 value = local.key_pair_reformatted
}