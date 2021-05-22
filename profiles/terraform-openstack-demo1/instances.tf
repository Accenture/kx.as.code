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
    openstack_networking_secgroup_v2.kx_security_group
  ]
  name      = "kx-main"
  image_id  = "cff30f5e-a4ec-457e-a925-fb99392cc2be"
  region    = "RegionOne"
  flavor_id = "4"
  key_pair  = openstack_compute_keypair_v2.kx-keypair.name
  security_groups = [ openstack_networking_secgroup_v2.kx_security_group.name ]

  block_device {
    boot_index            = 0
    delete_on_termination = true
    destination_type      = "volume"
    source_type           = "image"
    volume_size           = 40
    uuid                  = "cff30f5e-a4ec-457e-a925-fb99392cc2be"
  }

  network {
    uuid = openstack_networking_network_v2.kx-internal-network.id
    name = openstack_networking_subnet_v2.kx-internal-network-subnet.name
  }

  provisioner "local-exec" {
    command = "echo \"${self.network.0.fixed_ip_v4} ${self.name} ${self.name}.demo1.kx-as-code.local\"> hosts_file_entries.txt"
  }

}

resource "openstack_networking_floatingip_v2" "kx-worker-floating-ip" {
 depends_on = [ 
   openstack_networking_network_v2.kx-internal-network  
 ]
 pool = "public"
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
    openstack_networking_secgroup_v2.kx_security_group
  ]
  name      = "kx-worker"
   image_id  = "a8d6b397-4727-4fb8-a056-e3c8026a9dd5"
  flavor_id = "4"
  key_pair  = openstack_compute_keypair_v2.kx-keypair.name
  region = "RegionOne"
  security_groups = [ openstack_networking_secgroup_v2.kx_security_group.name ]

  block_device {
    boot_index            = 0
    delete_on_termination = true
    destination_type      = "volume"
    source_type           = "image"
    volume_size           = 40
    uuid                  = "a8d6b397-4727-4fb8-a056-e3c8026a9dd5"
  }

  network {
    uuid = openstack_networking_network_v2.kx-internal-network.id
    name = openstack_networking_subnet_v2.kx-internal-network-subnet.name
  }

  provisioner "local-exec" {
    command = "echo \"${self.network.0.fixed_ip_v4} ${self.name} ${self.name}.demo1.kx-as-code.local\">> hosts_file_entries.txt"
  }

}


