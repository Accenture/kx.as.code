provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "folder" {
  path          = var.vsphere_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "kx-main-demo1" {
  name                       = "kx-main-demo1"
  folder                     = var.vsphere_folder
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  datacenter_id              = data.vsphere_datacenter.dc.id

  num_cpus = var.main_node_num_cpus
  memory   = var.main_node_memory
  guest_id = var.main_node_guest_id

  ovf_deploy {
    local_ovf_path       = "C:/Users/Patrick/github.com/kx.as.code/base-vm/output-main-demo/vmware-vsphere-0.6.3/kx.as.code-main-demo-0.6.3.ova"
    disk_provisioning    = "thin"
    ip_protocol          = "IPV4"
    ip_allocation_policy = "STATIC_MANUAL"
    ovf_network_map = {
      "ESX-port-1" = data.vsphere_network.network.id
      "ESX-port-2" = data.vsphere_network.network.id
    }
  }

  vapp {
    properties = {
      "guestinfo.hostname"  = "kx-main-test",
      "guestinfo.ipaddress" = "192.168.50.100",
      "guestinfo.netmask"   = "255.255.255.0",
      "guestinfo.gateway"   = "192.168.50.1",
      "guestinfo.dns"       = "192.168.50.1",
      "guestinfo.domain"    = "lab-kx-as-code.local",
      "guestinfo.ntp"       = "pool.ntp.org",
      "guestinfo.password"  = "L3arnandshare",
      "guestinfo.ssh"       = "True"
    }
  }
}
