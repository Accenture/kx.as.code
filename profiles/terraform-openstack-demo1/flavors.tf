resource "openstack_compute_flavor_v2" "kx_main_admin_flavor" {
  name  = "kx-main"
  ram   = local.admin_main_node_memory
  vcpus = local.admin_main_node_cpu_cores
  disk  = "40"
}

resource "openstack_compute_flavor_v2" "kx_main_replica_flavor" {
  name  = "kx-main"
  ram   = local.replica_main_node_memory
  vcpus = local.replica_main_node_cpu_cores
  disk  = "40"
}

resource "openstack_compute_flavor_v2" "kx_worker_flavor" {
  name  = "kx.worker"
  ram   = local.worker_node_memory
  vcpus = local.worker_node_cpu_cores
  disk  = "40"
}
