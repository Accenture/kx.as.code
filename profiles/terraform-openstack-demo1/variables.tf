# Set variables from JSON and environment variabled. Environment variables have priority and will override values from the JSON

# Get veriables from JSON
locals {
  raw_data = jsondecode(file("profile-config.json"))
  kx_version = local.raw_data.config.vm_properties.kx_version
  main_node_cpu_cores = local.raw_data.config.vm_properties.main_node_cpu_cores
  main_node_memory = local.raw_data.config.vm_properties.main_node_memory
  worker_node_count = local.raw_data.config.vm_properties.worker_node_count
  worker_node_cpu_cores = local.raw_data.config.vm_properties.worker_node_cpu_cores
  worker_node_memory = local.raw_data.config.vm_properties.worker_node_memory
  num_local_one_gb_volumes = local.raw_data.config.local_volumes.one_gb
  num_local_five_gb_volumes = local.raw_data.config.local_volumes.five_gb
  num_local_ten_gb_volumes = local.raw_data.config.local_volumes.ten_gb
  num_local_thirty_gb_volumes = local.raw_data.config.local_volumes.thirty_gb
  num_local_fifty_gb_volumes = local.raw_data.config.local_volumes.fifty_gb
  local_storage_volume_size = local.raw_data.config.local_volumes.one_gb + (local.raw_data.config.local_volumes.five_gb * 5) + (local.raw_data.config.local_volumes.ten_gb * 10) + (local.raw_data.config.local_volumes.thirty_gb * 30) + (local.raw_data.config.local_volumes.fifty_gb * 50) + 1
  glusterfs_storage_volume_size = local.raw_data.config.glusterFsDiskSize + 1
  external_network_id = local.raw.data.config.external_network_id
}

# Get environment variables
variable "KX_MAIN_IMAGE_ID" {
  type = string
}

variable "KX_WORKER_IMAGE_ID" {
  type = string
}

variable "OS_EXTERNAL_NETWORK_ID" {
  type = string
  default = local.external_network_id
}

variable "MAIN_NODE_CPU_CORES" {
  type = string
  default = local.main_node_cpu_cores
}

variable "MAIN_NODE_MEMORY" {
  type = string
  default = local.main_node_memory
}

variable "WORKER_NODE_COUNT" {
  type = string
  default = local.worker_node_count
}

variable "WORKER_NODE_CPU_CORES" {
  type = string
  default = local.worker_node_cpu_cores
}

variable "WORKER_NODE_MEMORY" {
  type = string
  default = local.worker_node_memory
}

variable "NUM_LOCAL_ONE_GB_VOLUMES" {
  type = string
  default = local.num_local_one_gb_volumes
}

variable "NUM_LOCAL_FIVE_GB_VOLUMES" {
  type = string
  default = local.num_local_five_gb_volumes
}

variable "NUM_LOCAL_TEN_GB_VOLUMES" {
  type = string
  default = local.num_local_ten_gb_volumes
}

variable "NUM_LOCAL_THIRTY_GB_VOLUMES" {
  type = string
  default = local.num_local_thirty_gb_volumes
}

variable "NUM_LOCAL_FIFTY_GB_VOLUMES" {
  type = string
  default = local.num_local_fifty_gb_volumes
}

variable "LOCAL_STORAGE_VOLUME_SIZE" {
  type = string
  default = local.local_storage_volume_size
}

variable "GLUSTERFS_STORAGE_VOLUME_SIZE" {
  type = string
  default = local.glusterfs_storage_volume_size
}
