resource "openstack_blockstorage_volume_v3" "kx-main-local-storage" {
  region = "RegionOne"
  name  = "kx-main-local-storage"
  description = "kx-main-local-storage"
  size = local.local_storage_volume_size
}

resource "openstack_blockstorage_volume_v3" "kx-main-glusterfs-storage" {
  region = "RegionOne"
  name  = "kx-main-glusterfs-storage"
  description = "kx-main-glusterfs-storage"
  size  = local.glusterfs_storage_volume_size
}

resource "openstack_compute_volume_attach_v2" "kx-main-local-storage-attach" {
  depends_on = [
    openstack_blockstorage_volume_v3.kx-main-local-storage,
    openstack_compute_instance_v2.kx-main
  ]
  volume_id   = openstack_blockstorage_volume_v3.kx-main-local-storage.id
  instance_id = openstack_compute_instance_v2.kx-main.id
}

resource "openstack_compute_volume_attach_v2" "kx-main-glusterfs-storage-attach" {
  depends_on = [
    openstack_blockstorage_volume_v3.kx-main-glusterfs-storage,
    openstack_compute_instance_v2.kx-main
  ]
  volume_id   = openstack_blockstorage_volume_v3.kx-main-glusterfs-storage.id
  instance_id = openstack_compute_instance_v2.kx-main.id
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
