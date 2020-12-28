provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "sfo01-w03dc"
}

data "vsphere_datastore" "datastore" {
  name          = "sfo01w03ds00"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "sfo01-w03rp-user-vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "sfo01-w03-vds01-InfraSvcs"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "kx-main-demo1" {
  name                       = "kx-main-demo1"
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id

  datacenter_id              = data.vsphere_datacenter.dc.id
  ovf_deploy {
    local_ovf_path       = "/Data/kx.as.code-main-demo-0.6.3.ova"
    disk_provisioning    = "thin"
    ip_protocol          = "IPV4"
    ip_allocation_policy = "STATIC_MANUAL"
    ovf_network_map = {
      "ESX-port-1" = data.vsphere_network.network.id
    }
  }
}

resource "vsphere_virtual_machine" "kx-worker1-demo1" {
  name                       = "kx-worker1-demo1"
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id

  datacenter_id              = data.vsphere_datacenter.dc.id
  ovf_deploy {
    local_ovf_path       = "/Data/kx.as.code-worker-demo-0.6.3.ova"
    disk_provisioning    = "thin"
    ip_protocol          = "IPV4"
    ip_allocation_policy = "STATIC_MANUAL"
    ovf_network_map = {
      "ESX-port-1" = data.vsphere_network.network.id
    }
  }
}


resource "vsphere_virtual_machine" "kx-worker2-demo1" {
  name                       = "kx-worker2-demo1"
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id

  datacenter_id              = data.vsphere_datacenter.dc.id
  ovf_deploy {
    local_ovf_path       = "/Data/kx.as.code-worker-demo-0.6.3.ova"
    disk_provisioning    = "thin"
    ip_protocol          = "IPV4"
    ip_allocation_policy = "STATIC_MANUAL"
    ovf_network_map = {
      "ESX-port-1" = data.vsphere_network.network.id
    }
  }
}


