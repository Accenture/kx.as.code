variable "vsphere_user" {
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  default = "L3arnandshare!"
}

variable "vsphere_datacenter" {
  default = "kx01dc01"
}

variable "vsphere_server" {
  default = "192.168.40.158"
}

variable "vsphere_host" {
  default = "192.168.40.160"
}

variable "vsphere_folder" {
  default = "kx.as.code-vms"
}

variable "vsphere_network" {
  default = "kx01infranet01"
}

variable "vsphere_datastore" {
  default = "datastore1"
}

variable "vsphere_resource_pool" {
  default = "kx01cl01/Resources"
}

variable "main_node_num_cpus" {
  default = 2
}

variable "main_node_memory" {
  default = 8192
}

variable "main_node_guest_id" {
  default = "other3xLinux64Guest"
}

variable "worker_node_num_cpus" {
  default = 2
}

variable "worker_node_memory" {
  default = 8192
}

variable "worker_node_guest_id" {
  default = "other3xLinux64Guest"
}
