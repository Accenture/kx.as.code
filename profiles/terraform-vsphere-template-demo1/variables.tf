variable "vsphere_user" {
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  default = "VMware1!"
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

variable "vsphere_kx_vms_folder" {
  default = "kx.as.code-vms"
}

variable "vsphere_kx_templates_folder" {
  default = "kx.as.code-templates"
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

variable "kx_main_vm_template" {
  default = "kx.as.code-main-demo-0.6.4"
}

variable "kx_worker_vm_template" {
    default = "kx.as.code-worker-demo-0.6.4"
}

variable "main_node_num_cpus" {
  default = 2
}

variable "main_node_memory" {
  default = 8192
}

variable "main_node_guest_id" {
  default = "debian10_64Guest"
}

variable "worker_node_num_cpus" {
  default = 2
}

variable "worker_node_memory" {
  default = 8192
}

variable "worker_node_guest_id" {
  default = "debian10_64Guest"
}
