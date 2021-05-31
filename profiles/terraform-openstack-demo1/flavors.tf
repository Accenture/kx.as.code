resource "openstack_compute_flavor_v2" "kx-main-flavor" {
  name  = "kx.main"
  ram   = var.MAIN_NODE_MEMORY
  vcpus = var.MAIN_NODE_CPU_CORES
  disk  = "40"
}

resource "openstack_compute_flavor_v2" "kx-worker-flavor" {
  name  = "kx.worker"
  ram   = var.WORKER_NODE_MEMORY
  vcpus = var.WORKER_NODE_CPU_CORES
  disk  = "40"
}
