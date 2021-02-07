terraform {
  required_version = ">= 0.13"
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
      #
      # For more information, see the provider source documentation:
      # https://github.com/josenk/terraform-provider-esxi
      # https://registry.terraform.io/providers/josenk/esxi
    }
  }
}

output "kx-main-ip" {
  value = esxi_guest.kx-main-demo2.ip_address
}

output "kx-worker1-ip" {
  value = esxi_guest.kx-worker1-demo2.ip_address
}

output "kx-worker2-ip" {
  value = esxi_guest.kx-worker2-demo2.ip_address
}

provider "esxi" {
  esxi_hostname = "192.168.40.160"
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = "root"
  esxi_password = "L3arnandshare!"
}

resource "esxi_guest" "kx-main-demo2" {

  guest_name = "kx-main-demo2"
  power      = "on"
  disk_store = "datastore1"
  guestos    = "debian10_64Guest"
  memsize    = 16384
  numvcpus   = 4

  ovf_source = "../output-main-demo/vmware/kx.as.code-main-demo-0.5.1.ovf"

  network_interfaces {
    virtual_network = "VM Network"
  }

  virtual_disks {
    virtual_disk_id = esxi_virtual_disk.LocalStorage1.id
    slot            = "0:1"
  }
  virtual_disks {
    virtual_disk_id = esxi_virtual_disk.GlusterFsStorage1.id
    slot            = "0:2"
  }

  provisioner "file" {

    source      = "./autoSetup.json"
    destination = "/home/kx.hero/Kubernetes/autoSetup.json"

    connection {
      type     = "ssh"
      user     = "kx.hero"
      password = "L3arnandshare"
      host     = esxi_guest.kx-main-demo2.ip_address
    }

  }

}

resource "esxi_guest" "kx-worker1-demo2" {

  guest_name = "kx-worker1-demo2"
  power      = "on"
  disk_store = "datastore1"
  guestos    = "debian10_64Guest"
  memsize    = 16384
  numvcpus   = 4

  ovf_source = "../output-worker-demo/vmware/kx.as.code-worker-demo-0.5.1.ovf"

  network_interfaces {
    virtual_network = "VM Network"
  }

  virtual_disks {
    virtual_disk_id = esxi_virtual_disk.LocalStorage2.id
    slot            = "0:1"
  }

  provisioner "file" {

    source      = "./autoSetup.json"
    destination = "/home/kx.hero/Kubernetes/autoSetup.json"

    connection {
      type     = "ssh"
      user     = "kx.hero"
      password = "L3arnandshare"
      host     = esxi_guest.kx-worker1-demo2.ip_address
    }

  }

  provisioner "remote-exec" {

    inline = [
      "sudo hostnamectl set-hostname kx-worker1"
    ]

    connection {
      type     = "ssh"
      user     = "kx.hero"
      password = "L3arnandshare"
      host     = esxi_guest.kx-worker1-demo2.ip_address
    }

  }

}

resource "esxi_guest" "kx-worker2-demo2" {

  guest_name = "kx-worker2-demo2"
  power      = "on"
  disk_store = "datastore1"
  guestos    = "debian10_64Guest"
  memsize    = 16384
  numvcpus   = 4

  ovf_source = "../output-worker-demo/vmware/kx.as.code-worker-demo-0.5.1.ovf"

  network_interfaces {
    virtual_network = "VM Network"
  }

  virtual_disks {

    virtual_disk_id = esxi_virtual_disk.LocalStorage3.id
    slot            = "0:1"
  }

  provisioner "file" {

    source      = "./autoSetup.json"
    destination = "/home/kx.hero/Kubernetes/autoSetup.json"

    connection {
      type     = "ssh"
      user     = "kx.hero"
      password = "L3arnandshare"
      host     = esxi_guest.kx-worker2-demo2.ip_address
    }

  }

  provisioner "remote-exec" {

    inline = [
      "sudo hostnamectl set-hostname kx-worker2"
    ]

    connection {
      type     = "ssh"
      user     = "kx.hero"
      password = "L3arnandshare"
      host     = esxi_guest.kx-worker2-demo2.ip_address
    }

  }

}

resource "esxi_virtual_disk" "LocalStorage1" {
  virtual_disk_disk_store = "datastore1"
  virtual_disk_dir        = "kx-main-demo2"
  virtual_disk_size       = 105
  virtual_disk_name       = "kx-main-local_1.vmdk"
  virtual_disk_type       = "thin"
}

resource "esxi_virtual_disk" "GlusterFsStorage1" {
  virtual_disk_disk_store = "datastore1"
  virtual_disk_dir        = "kx-main-demo2"
  virtual_disk_size       = 105
  virtual_disk_name       = "kx-main-glusterfs_2.vmdk"
  virtual_disk_type       = "thin"
}

resource "esxi_virtual_disk" "LocalStorage2" {
  virtual_disk_disk_store = "datastore1"
  virtual_disk_dir        = "kx-worker1-demo2"
  virtual_disk_size       = 105
  virtual_disk_name       = "kx-worker1-local_1.vmdk"
  virtual_disk_type       = "thin"
}

resource "esxi_virtual_disk" "LocalStorage3" {
  virtual_disk_disk_store = "datastore1"
  virtual_disk_dir        = "kx-worker2-demo2"
  virtual_disk_size       = 105
  virtual_disk_name       = "kx-worker2-local_1.vmdk"
  virtual_disk_type       = "thin"
}
