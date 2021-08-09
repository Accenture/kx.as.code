resource "openstack_networking_network_v2" "kx_internal_network" {
  name           = "kx-internal-network"
  external       = false
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "kx_internal_network_subnet" {
  depends_on = [ openstack_networking_network_v2.kx_internal_network ]
  network_id = openstack_networking_network_v2.kx_internal_network.id
  cidr       = "10.20.76.0/24"
  ip_version  = 4
  enable_dhcp = true
}

resource "openstack_networking_router_v2" "kx_router" {
  name                = "kx-router"
  admin_state_up      = true
  external_network_id = "48af4f9c-b380-4451-a13b-ab609b672b95"
}

resource "openstack_networking_router_interface_v2" "kx_router_interface" {
  router_id = openstack_networking_router_v2.kx_router.id
  subnet_id = openstack_networking_subnet_v2.kx_internal_network_subnet.id
}

resource "openstack_networking_floatingip_v2" "kx_main_admin_floating_ip" {
  depends_on = [ 
    openstack_networking_network_v2.kx_internal_network
  ]
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "kx_main_admin_floating_ip_associate" {
  depends_on = [ openstack_networking_floatingip_v2.kx_main_admin_floating_ip ]
  floating_ip = openstack_networking_floatingip_v2.kx_main_admin_floating_ip.address
  instance_id = openstack_compute_instance_v2.kx_main_admin.id
}

resource "openstack_networking_floatingip_v2" "kx_main_replica_floating_ip" {
  depends_on = [
    openstack_networking_network_v2.kx_internal_network
  ]
  pool = "public"
  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1
}

resource "openstack_compute_floatingip_associate_v2" "kx_main_replica_floating_ip_associate" {
  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1
  depends_on = [ openstack_networking_floatingip_v2.kx_main_replica_floating_ip ]
  floating_ip = element(openstack_networking_floatingip_v2.kx_main_replica_floating_ip.*.address, count.index)
  instance_id = element(openstack_compute_instance_v2.kx_main_replica.*.id, count.index)
}

resource "openstack_networking_floatingip_v2" "kx_worker_floating_ip" {
  depends_on = [
    openstack_networking_network_v2.kx_internal_network
  ]
  pool = "public"
  count = local.worker_node_count
}

resource "openstack_compute_floatingip_associate_v2" "kx_worker_floating_ip_associate" {
  count = local.worker_node_count
  depends_on = [ openstack_networking_floatingip_v2.kx_worker_floating_ip ]
  floating_ip = element(openstack_networking_floatingip_v2.kx_worker_floating_ip.*.address, count.index)
  instance_id = element(openstack_compute_instance_v2.kx_worker.*.id, count.index)
}

