# Set variables from JSON and environment variabled. Environment variables have priority and will override values from the JSON

# Get veriables from JSON
locals {
  raw_data = jsondecode(file("profile-config.json"))
  raw_version = jsondecode(file("../../version.json"))
  kx_version = local.raw_version.version
  main_node_count = local.raw_data.config.vm_properties.main_node_count
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
  external_network_id = local.raw_data.config.vm_properties.openstack.external_network_id
  kx_main_image_id = local.raw_data.config.vm_properties.openstack.kx_main_image_id
  kx_worker_image_id = local.raw_data.config.vm_properties.openstack.kx_worker_image_id
}
