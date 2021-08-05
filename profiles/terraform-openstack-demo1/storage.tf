resource "openstack_blockstorage_volume_v3" "kx-main-admin-local-storage" {
  region = "RegionOne"
  name  = "kx-main-local-storage"
  description = "kx-main-local-storage"
  size = local.local_storage_volume_size
}

resource "openstack_blockstorage_volume_v3" "kx-main-admin-glusterfs-storage" {
  region = "RegionOne"
  name  = "kx-main-glusterfs-storage"
  description = "kx-main-glusterfs-storage"
  size  = local.glusterfs_storage_volume_size
}

resource "openstack_compute_volume_attach_v2" "kx-main-admin-local-storage-attach" {
  depends_on = [
    openstack_blockstorage_volume_v3.kx-main-admin-local-storage,
    openstack_compute_instance_v2.kx-main-admin
  ]
  volume_id   = openstack_blockstorage_volume_v3.kx-main-admin-local-storage.id
  instance_id = openstack_compute_instance_v2.kx-main-admin.id
}

resource "openstack_compute_volume_attach_v2" "kx-main-admin-glusterfs-storage-attach" {
  depends_on = [
    openstack_blockstorage_volume_v3.kx-main-admin-glusterfs-storage,
    openstack_compute_instance_v2.kx-main-admin
  ]
  volume_id   = openstack_blockstorage_volume_v3.kx-main-admin-glusterfs-storage.id
  instance_id = openstack_compute_instance_v2.kx-main-admin.id
}

resource "openstack_blockstorage_volume_v3" "kx-main-additional-local-storage" {
  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1
  region = "RegionOne"
  name  = "kx-main-additional-local-storage${count.index + 1}"
  description = "kx-main-additional-local-storage"
  size = local.local_storage_volume_size
}

resource "openstack_compute_volume_attach_v2" "kx-main-additional-local-storage-attach" {
  depends_on = [
    openstack_blockstorage_volume_v3.kx-main-additional-local-storage,
    openstack_compute_instance_v2.kx-main-additional
  ]
  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1
  volume_id   = element(openstack_blockstorage_volume_v3.kx-main-additional-local-storage.*.id, count.index)
  instance_id = element(openstack_compute_instance_v2.kx-main-additional.*.id, count.index)
}

resource "openstack_blockstorage_volume_v3" "kx-worker-local-storage" {
  count = local.worker_node_count
  region = "RegionOne"
  name  = "kx-worker-local-storage${count.index + 1}"
  description = "kx-worker-local-storage"
  size = local.local_storage_volume_size
}

resource "openstack_compute_volume_attach_v2" "kx-worker-local-storage-attach" {
  depends_on = [
    openstack_blockstorage_volume_v3.kx-worker-local-storage,
    openstack_compute_instance_v2.kx-worker
  ]
  count = local.worker_node_count
  volume_id   = element(openstack_blockstorage_volume_v3.kx-worker-local-storage.*.id, count.index)
  instance_id = element(openstack_compute_instance_v2.kx-worker.*.id, count.index)
}
