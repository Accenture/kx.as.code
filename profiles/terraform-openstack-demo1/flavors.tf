resource "openstack_compute_flavor_v2" "kx-main-flavor" {
  name  = "kx.main"
  ram   = local.main_node_memory
  vcpus = local.main_node_cpu_cores
  disk  = "40"
}

resource "openstack_compute_flavor_v2" "kx-worker-flavor" {
  name  = "kx.worker"
  ram   = local.worker_node_memory
  vcpus = local.worker_node_cpu_cores
  disk  = "40"
}
