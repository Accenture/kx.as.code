resource "openstack_blockstorage_volume_v3" "kx_main_admin_local_storage" {
  region = "RegionOne"
  name  = "kx-main-local-storage"
  description = "kx-main-local-storage"
  size = local.local_storage_volume_size
}

resource "openstack_blockstorage_volume_v3" "kx_main_admin_glusterfs_storage" {
  region = "RegionOne"
  name  = "kx-main-glusterfs-storage"
  description = "kx-main-glusterfs-storage"
  size  = local.glusterfs_storage_volume_size
}

resource "openstack_compute_volume_attach_v2" "kx_main_admin_local_storage_attach" {
  depends_on = [
    openstack_blockstorage_volume_v3.kx_main_admin_local_storage,
    openstack_compute_instance_v2.kx_main_admin
  ]
  volume_id   = openstack_blockstorage_volume_v3.kx_main_admin_local_storage.id
  instance_id = openstack_compute_instance_v2.kx_main_admin.id
}

resource "openstack_compute_volume_attach_v2" "kx_main_admin_glusterfs_storage-attach" {
  depends_on = [
    openstack_blockstorage_volume_v3.kx_main_admin_glusterfs_storage,
    openstack_compute_instance_v2.kx_main_admin
  ]
  volume_id   = openstack_blockstorage_volume_v3.kx_main_admin_glusterfs_storage.id
  instance_id = openstack_compute_instance_v2.kx_main_admin.id
}

resource "openstack_blockstorage_volume_v3" "kx_main_replica_local_storage" {
  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1
  region = "RegionOne"
  name  = "kx_main_replica-local-storage${count.index + 1}"
  description = "kx_main_replica-local-storage"
  size = local.local_storage_volume_size
}

resource "openstack_compute_volume_attach_v2" "kx_main_replica_local_storage_attach" {
  depends_on = [
    openstack_blockstorage_volume_v3.kx_main_replica_local_storage,
    openstack_compute_instance_v2.kx_main_replica
  ]
  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1
  volume_id   = element(openstack_blockstorage_volume_v3.kx_main_replica_local_storage.*.id, count.index)
  instance_id = element(openstack_compute_instance_v2.kx_main_replica.*.id, count.index)
}

resource "openstack_blockstorage_volume_v3" "kx_worker_local_storage" {
  count = local.worker_node_count
  region = "RegionOne"
  name  = "kx-worker-local-storage${count.index + 1}"
  description = "kx-worker-local-storage"
  size = local.local_storage_volume_size
}

resource "openstack_compute_volume_attach_v2" "kx_worker_local_storage_attach" {
  depends_on = [
    openstack_blockstorage_volume_v3.kx_worker_local_storage,
    openstack_compute_instance_v2.kx_worker
  ]
  count = local.worker_node_count
  volume_id   = element(openstack_blockstorage_volume_v3.kx_worker_local_storage.*.id, count.index)
  instance_id = element(openstack_compute_instance_v2.kx_worker.*.id, count.index)
}
