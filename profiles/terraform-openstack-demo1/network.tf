resource "openstack_compute_secgroup_v2" "kx_security_group" {
  name        = "kx_security_group"
  description = "KX.AS.CODE Security Group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

rule {
    from_port   = 8099
    to_port     = 8099
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

rule {
    from_port   = 8043
    to_port     = 8043
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

rule {
    from_port   = 7080
    to_port     = 7080
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

rule {
    from_port   = 7043
    to_port     = 7043
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

rule {
    from_port   = 6080
    to_port     = 6080
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

rule {
    from_port   = 6043
    to_port     = 6043
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 5080
    to_port     = 5080
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

rule {
    from_port   = 5043
    to_port     = 5043
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 4080
    to_port     = 4080
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

rule {
    from_port   = 4043
    to_port     = 4043
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

}

resource "openstack_networking_network_v2" "kx-internal-network" {
  name           = "kx-internal-network"
  external       = false
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "kx-internal-network-subnet" {
  depends_on = [ openstack_networking_network_v2.kx-internal-network ]
  network_id = openstack_networking_network_v2.kx-internal-network.id
  cidr       = "10.20.76.0/24"
  dns_nameservers = [ "10.20.76.2", "8.8.8.8"]
  ip_version  = 4
  enable_dhcp = true
}

resource "openstack_networking_router_v2" "kx-router" {
  name                = "kx-router"
  admin_state_up      = true
  external_network_id = "48af4f9c-b380-4451-a13b-ab609b672b95"
}

resource "openstack_networking_router_interface_v2" "kx-router-interface" {
  router_id = openstack_networking_router_v2.kx-router.id
  subnet_id = openstack_networking_subnet_v2.kx-internal-network-subnet.id
}

resource "openstack_networking_floatingip_v2" "kx-main-floating-ip" {
  depends_on = [ 
    openstack_networking_network_v2.kx-internal-network
  ]
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "kx-main-floating-ip-associate" {
 depends_on = [ openstack_networking_floatingip_v2.kx-main-floating-ip ]
 floating_ip = openstack_networking_floatingip_v2.kx-main-floating-ip.address
 instance_id = openstack_compute_instance_v2.kx-main.id
}

resource "openstack_compute_floatingip_associate_v2" "kx-worker-floating-ip-associate" {
 depends_on = [ openstack_networking_floatingip_v2.kx-worker-floating-ip ]
 floating_ip = openstack_networking_floatingip_v2.kx-worker-floating-ip.address
 instance_id = openstack_compute_instance_v2.kx-worker.id
}

