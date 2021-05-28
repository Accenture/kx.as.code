resource "openstack_compute_keypair_v2" "kx-keypair" {
  name = "kx-keypair"
}

# Create KX-Main server
resource "openstack_compute_instance_v2" "kx-main" {
  depends_on = [ 
    openstack_compute_keypair_v2.kx-keypair,
    openstack_networking_network_v2.kx-internal-network,
    openstack_networking_subnet_v2.kx-internal-network-subnet,
    openstack_blockstorage_volume_v3.kx-main-local-storage,
    openstack_blockstorage_volume_v3.kx-main-glusterfs-storage,
    openstack_networking_floatingip_v2.kx-main-floating-ip,
    openstack_networking_secgroup_v2.kx_security_group,
    openstack_compute_flavor_v2.kx-main-flavor
  ]
  name      = "kx-main"
  image_id  = "4afc68e8-907d-4dfb-a790-c5cd30272eeb"
  region    = "RegionOne"
  flavor_id = openstack_compute_flavor_v2.kx-main-flavor.id
  key_pair  = openstack_compute_keypair_v2.kx-keypair.name
  security_groups = [ openstack_networking_secgroup_v2.kx_security_group.name ]
  user_data       = "#cloud-config\nhostname: kx-main"

  block_device {
    boot_index            = 0
    delete_on_termination = true
    destination_type      = "volume"
    source_type           = "image"
    volume_size           = 40
    uuid                  = "4afc68e8-907d-4dfb-a790-c5cd30272eeb"
  }

  network {
    uuid = openstack_networking_network_v2.kx-internal-network.id
    name = openstack_networking_subnet_v2.kx-internal-network-subnet.name
  }

  provisioner "local-exec" {
    command = "echo \"${self.network.0.fixed_ip_v4} ${self.name} ${self.name}.demo1.kx-as-code.local\"> hosts_file_entries.txt"
  }

}

# Create KX-Worker server
resource "openstack_compute_instance_v2" "kx-worker" {
  depends_on = [ 
    openstack_compute_keypair_v2.kx-keypair,
    openstack_networking_network_v2.kx-internal-network,
    openstack_networking_subnet_v2.kx-internal-network-subnet,
    openstack_compute_instance_v2.kx-main,
    openstack_blockstorage_volume_v3.kx-worker-local-storage,
    openstack_networking_floatingip_v2.kx-worker-floating-ip,
    openstack_networking_secgroup_v2.kx_security_group,
    openstack_compute_flavor_v2.kx-worker-flavor
  ]
  name      = "kx-worker${count.index + 1}"
  image_id  = "cac49823-c9e0-422d-8d94-4e64b2971c41"
  flavor_id = openstack_compute_flavor_v2.kx-worker-flavor.id
  key_pair  = openstack_compute_keypair_v2.kx-keypair.name
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
    uuid                  = "cac49823-c9e0-422d-8d94-4e64b2971c41"
  }

  network {
    uuid = openstack_networking_network_v2.kx-internal-network.id
    name = openstack_networking_subnet_v2.kx-internal-network-subnet.name
  }

  provisioner "local-exec" {
    command = "echo \"${self.network.0.fixed_ip_v4} ${self.name} ${self.name}.demo1.kx-as-code.local\">> hosts_file_entries.txt"
  }

}


