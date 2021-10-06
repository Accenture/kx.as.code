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

data "vsphere_virtual_machine" "kx_main_template" {
  name          = var.kx_main_vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "kx_worker_template" {
  name          = var.kx_worker_vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "kx-main-demo1" {
  name             = "kx-main-demo1"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.main_node_num_cpus
  memory   = var.main_node_memory
  guest_id = var.main_node_guest_id

  scsi_type = data.vsphere_virtual_machine.kx_main_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.kx_main_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.kx_main_template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.kx_main_template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.kx_main_template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.kx_main_template.id

    customize {
      linux_options {
        host_name = "kx-main"
        domain    = "team1.kx-as-code.local"
      }

      network_interface {
        ipv4_address = "10.0.0.10"
        ipv4_netmask = 24
      }
      ipv4_gateway = "10.0.0.1"
    }
  }
}

resource "vsphere_virtual_machine" "kx-worker-demo1" {
  count            = 2
  name             = "kx-worker${count.index + 1}-demo1"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.worker_node_num_cpus
  memory   = var.worker_node_memory
  guest_id = var.worker_node_guest_id

  scsi_type = data.vsphere_virtual_machine.kx_worker_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.kx_worker_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.kx_worker_template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.kx_worker_template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.kx_worker_template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.kx_worker_template.id

    customize {
      linux_options {
        host_name = "kx-worker${count.index + 1}"
        domain    = "team1.kx-as-code.local"
      }

      network_interface {
        ipv4_address = "10.0.0.${11 + count.index}"
        ipv4_netmask = 24
      }
      ipv4_gateway = "10.0.0.1"
    }
  }
}
