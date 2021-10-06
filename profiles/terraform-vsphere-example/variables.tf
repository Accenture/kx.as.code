variable "vsphere_user" {
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  default = "VMware1!!"
}

variable "vsphere_datacenter" {
  default = "kx01-dc01"
}

variable "vsphere_server" {
  default = "192.168.40.191"
}

variable "vsphere_host" {
  default = "192.168.40.184"
}

variable "vsphere_folder" {
  default = "kx.as.code-vms"
}

variable "vsphere_network" {
  default = "kx01-m01-vds01-vmnet"
}

variable "vsphere_datastore" {
  default = "dsEsx01a"
}

variable "vsphere_resource_pool" {
  default = "kx01-m01-cl01/Resources"
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
