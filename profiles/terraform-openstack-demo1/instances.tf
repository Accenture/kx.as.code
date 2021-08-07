resource "openstack_compute_keypair_v2" "kx_keypair" {
  name = "kx-keypair"
}

# Create KX-Main Admin server
resource "openstack_compute_instance_v2" "kx_main_admin" {
  depends_on = [ 
    openstack_compute_keypair_v2.kx_keypair,
    openstack_networking_network_v2.kx_internal_network,
    openstack_networking_subnet_v2.kx_internal_network_subnet,
    openstack_blockstorage_volume_v3.kx_main_admin_local_storage,
    openstack_blockstorage_volume_v3.kx_main_admin_glusterfs_storage,
    openstack_networking_floatingip_v2.kx_main_admin_floating_ip,
    openstack_networking_secgroup_v2.kx_security_group,
    openstack_compute_flavor_v2.kx_main_admin_flavor
  ]
  name      = "kx-main1"
  image_id  = local.kx_main_image_id
  region    = "RegionOne"
  flavor_id = openstack_compute_flavor_v2.kx_main_admin_flavor.id
  key_pair  = openstack_compute_keypair_v2.kx_keypair.name
  security_groups = [ openstack_networking_secgroup_v2.kx_security_group.name ]
  user_data       = "#cloud-config\nhostname: kx-main1"

  block_device {
    boot_index            = 0
    delete_on_termination = true
    destination_type      = "volume"
    source_type           = "image"
    volume_size           = 40
    uuid                  = local.kx_main_image_id
  }

  network {
    uuid = openstack_networking_network_v2.kx_internal_network.id
    name = openstack_networking_subnet_v2.kx_internal_network_subnet.name
  }

  provisioner "local-exec" {
    command = "echo \"${self.network.0.fixed_ip_v4} ${self.name} ${self.name}.demo1.kx-as-code.local\"> hosts_file_entries.txt"
  }

}

# Create KX-Main Replica servers
resource "openstack_compute_instance_v2" "kx_main_replica" {
  depends_on = [
    openstack_compute_keypair_v2.kx_keypair,
    openstack_networking_network_v2.kx_internal_network,
    openstack_networking_subnet_v2.kx_internal_network_subnet,
    openstack_compute_instance_v2.kx_main_admin,
    openstack_blockstorage_volume_v3.kx_main_replica_local_storage,
    openstack_networking_floatingip_v2.kx_main_replica_floating_ip,
    openstack_networking_secgroup_v2.kx_security_group,
    openstack_compute_flavor_v2.kx_main_replica_flavor
  ]
  name = "kx-main${count.index + 2}"
  image_id = local.kx_supplemental_image_id
  flavor_id = openstack_compute_flavor_v2.kx_main_replica_flavor.id
  key_pair = openstack_compute_keypair_v2.kx_keypair.name
  region = "RegionOne"
  security_groups = [ openstack_networking_secgroup_v2.kx_security_group.name ]
  user_data = "#cloud-config\nhostname: kx-main${count.index + 2}"
  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1

  block_device {
    boot_index = 0
    delete_on_termination = true
    destination_type = "volume"
    source_type = "image"
    volume_size = 40
    uuid = local.kx_supplemental_image_id
  }

  network {
    uuid = openstack_networking_network_v2.kx_internal_network.id
    name = openstack_networking_subnet_v2.kx_internal_network_subnet.name
  }

  provisioner "local-exec" {
    command = "echo \"${self.network.0.fixed_ip_v4} ${self.name} ${self.name}.demo1.kx-as-code.local\">> hosts_file_entries.txt"
  }

}

# Create KX-Worker server
resource "openstack_compute_instance_v2" "kx_worker" {
  depends_on = [ 
    openstack_compute_keypair_v2.kx_keypair,
    openstack_networking_network_v2.kx_internal_network,
    openstack_networking_subnet_v2.kx_internal_network_subnet,
    openstack_compute_instance_v2.kx_main_admin,
    openstack_blockstorage_volume_v3.kx_worker_local_storage,
    openstack_networking_floatingip_v2.kx_worker_floating_ip,
    openstack_networking_secgroup_v2.kx_security_group,
    openstack_compute_flavor_v2.kx_worker_flavor
  ]
  name      = "kx-worker${count.index + 1}"
  image_id  = local.kx_supplemental_image_id
  flavor_id = openstack_compute_flavor_v2.kx_worker_flavor.id
  key_pair  = openstack_compute_keypair_v2.kx_keypair.name
  region = "RegionOne"
  security_groups = [ openstack_networking_secgroup_v2.kx_security_group.name ]
  user_data       = "#cloud-config\nhostname: kx-worker${count.index + 1}"
  count = local.worker_node_count

  block_device {
    boot_index            = 0
    delete_on_termination = true
    destination_type      = "volume"
    source_type           = "image"
    volume_size           = 40
    uuid                  = local.kx_supplemental_image_id
  }

  network {
    uuid = openstack_networking_network_v2.kx_internal_network.id
    name = openstack_networking_subnet_v2.kx_internal_network_subnet.name
  }

  provisioner "local-exec" {
    command = "echo \"${self.network.0.fixed_ip_v4} ${self.name} ${self.name}.demo1.kx-as-code.local\">> hosts_file_entries.txt"
  }

}


