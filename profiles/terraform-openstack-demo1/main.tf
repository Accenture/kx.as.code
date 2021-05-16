terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "jp6z6B8539OrtnqvjRu58Bm2MylLwR7z"
  auth_url    = "http://10.2.76.201:5000/v3/"
  region      = "microstack"
}


resource "openstack_networking_network_v2" "kx-internal-network" {
  name           = "kx-internal-network"
  external       = false
  admin_state_up = true
}

#resource "openstack_networking_network_v2" "kx-external-network" {
#  name           = "kx-external-network"
#  external       = true
#  #admin_state_up = true
#}

resource "openstack_networking_subnet_v2" "kx-internal-network-subnet" {
  depends_on = [ openstack_networking_network_v2.kx-internal-network ]
  network_id = openstack_networking_network_v2.kx-internal-network.id
  cidr       = "10.100.76.0/24"
  ip_version  = 4
  enable_dhcp = true
}

#resource "openstack_networking_subnet_v2" "kx-external-network-subnet" {
#  depends_on = [ openstack_networking_network_v2.kx-external-network ]
#  network_id = openstack_networking_network_v2.kx-external-network.id
#  cidr       = "192.100.76.0/24"
#  ip_version  = 4
#  #enable_dhcp = true
#}

resource "openstack_networking_router_v2" "kx-router" {
  name                = "kx-router"
  admin_state_up      = true
  external_network_id = "a5f6d6c9-6327-4377-826a-26b3606d87c6"
}

resource "openstack_networking_router_interface_v2" "kx-router-interface" {
  router_id = openstack_networking_router_v2.kx-router.id
  subnet_id = openstack_networking_subnet_v2.kx-internal-network-subnet.id
}

#resource "openstack_networking_subnet_route_v2" "subnet_route_1" {
#  subnet_id        = openstack_networking_network_v2.kx-internal-network.id
#  destination_cidr = "10.100.76.0/24"
#  next_hop         = "192.100.76.254"
#}

resource "openstack_networking_floatingip_v2" "kx-main-floating-ip" {
  depends_on = [ 
    openstack_networking_network_v2.kx-internal-network,
  ]
  pool = "external"
}

resource "openstack_compute_floatingip_associate_v2" "kx-main-floating-ip-associate" {
  depends_on = [ openstack_networking_floatingip_v2.kx-main-floating-ip ]
  floating_ip = openstack_networking_floatingip_v2.kx-main-floating-ip.address
  instance_id = openstack_compute_instance_v2.kx-main.id
}

resource "openstack_compute_keypair_v2" "kx-keypair" {
  name = "kx-keypair"
}

resource "openstack_blockstorage_volume_v3" "kx-main-local-storage" {
  #region = "microstack"
  name  = "kx-main-local-storage"
  description = "kx-main-local-storage"
  size = 100
}

resource "openstack_blockstorage_volume_v3" "kx-main-glusterfs-storage" {
  #region = "microstack"
  name  = "kx-main-glusterfs-storage"
  description = "kx-main-glusterfs-storage"
  size  = 100
}

resource "openstack_compute_volume_attach_v2" "kx-main-local-storage-attach" {
  depends_on = [ 
    openstack_blockstorage_volume_v3.kx-main-local-storage,
    openstack_compute_instance_v2.kx-main
  ]
  volume_id   = openstack_blockstorage_volume_v3.kx-main-local-storage.id
  instance_id = openstack_compute_instance_v2.kx-main.id
}

resource "openstack_compute_volume_attach_v2" "kx-main-glusterfs-storage-attach" {
  depends_on = [ 
    openstack_blockstorage_volume_v3.kx-main-glusterfs-storage,
    openstack_compute_instance_v2.kx-main
  ]
  volume_id   = openstack_blockstorage_volume_v3.kx-main-glusterfs-storage.id
  instance_id = openstack_compute_instance_v2.kx-main.id
}

# Create KX-Main server
resource "openstack_compute_instance_v2" "kx-main" {
  depends_on = [ 
    openstack_compute_keypair_v2.kx-keypair,
    openstack_networking_network_v2.kx-internal-network,
    openstack_networking_subnet_v2.kx-internal-network-subnet,
    openstack_blockstorage_volume_v3.kx-main-local-storage,
    openstack_blockstorage_volume_v3.kx-main-glusterfs-storage
  ]
  name      = "kx-main"
  image_id  = "63c682fd-671b-45db-89db-c46418ef3917"
  region    = "microstack"
  flavor_id = "4"
  key_pair  = openstack_compute_keypair_v2.kx-keypair.name

  block_device {
    uuid                  = "63c682fd-671b-45db-89db-c46418ef3917"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }

  block_device {
    source_type           = "blank"
    destination_type      = "volume"
    volume_size           = 100
    volume_type           = "__DEFAULT__"
    boot_index            = -1
    delete_on_termination = true
  }

  block_device {
    source_type           = "blank"
    destination_type      = "volume"
    volume_size           = 100
    volume_type           = "__DEFAULT__"
    boot_index            = -1
    delete_on_termination = true
  }

  network {
    uuid = openstack_networking_network_v2.kx-internal-network.id
    name = openstack_networking_subnet_v2.kx-internal-network-subnet.name
  }

}

resource "openstack_networking_floatingip_v2" "kx-worker-floating-ip" {
  depends_on = [ 
    openstack_networking_network_v2.kx-internal-network  ]
  pool = "external"
}

resource "openstack_compute_floatingip_associate_v2" "kx-worker-floating-ip-associate" {
  depends_on = [ openstack_networking_floatingip_v2.kx-worker-floating-ip ]
  floating_ip = openstack_networking_floatingip_v2.kx-worker-floating-ip.address
  instance_id = openstack_compute_instance_v2.kx-worker.id
}

resource "openstack_blockstorage_volume_v3" "kx-worker-local-storage" {
  #region = "microstack"
  name  = "kx-worker-local-storage"
  description = "kx-worker-local-storage"
  size = 100
}

resource "openstack_compute_volume_attach_v2" "kx-worker-local-storage-attach" {
  depends_on = [ 
    openstack_blockstorage_volume_v3.kx-worker-local-storage,
    openstack_compute_instance_v2.kx-worker
  ]
  volume_id   = openstack_blockstorage_volume_v3.kx-worker-local-storage.id
  instance_id = openstack_compute_instance_v2.kx-worker.id
}

# Create KX-Worker server
resource "openstack_compute_instance_v2" "kx-worker" {
  depends_on = [ 
    openstack_compute_keypair_v2.kx-keypair,
    openstack_networking_network_v2.kx-internal-network,
    openstack_networking_subnet_v2.kx-internal-network-subnet,
    openstack_compute_instance_v2.kx-main,
    openstack_blockstorage_volume_v3.kx-worker-local-storage
  ]
  name      = "kx-worker"
  image_id  = "2eb9d9f2-6ee8-4406-87c4-880a1b67a436"
  region    = "microstack"
  flavor_id = "4"
  key_pair  = openstack_compute_keypair_v2.kx-keypair.name

  block_device {
    uuid                  = "2eb9d9f2-6ee8-4406-87c4-880a1b67a436"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }

  block_device {
    source_type           = "blank"
    destination_type      = "volume"
    volume_size           = 100
    volume_type           = "__DEFAULT__"
    boot_index            = -1
    delete_on_termination = true
  }

  network {
    uuid = openstack_networking_network_v2.kx-internal-network.id
    name = openstack_networking_subnet_v2.kx-internal-network-subnet.name
  }

}

output "kx-main-floating-address" {
  value = openstack_compute_floatingip_associate_v2.kx-main-floating-ip-associate.*.floating_ip
}

output "kx-worker-floating-address" {
  value = openstack_compute_floatingip_associate_v2.kx-worker-floating-ip-associate.*.floating_ip
}