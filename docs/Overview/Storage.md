# Storage

There are two types of storage provisioned in KX.AS.CODE. For each, a dedicated virtual drive is attached via the Virtualization engine.

- Local storage volumes based on the Kubernetes [local storage provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner). The KX.AS.CODE installation scripts are located [here](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/core/local-storage){:target="\_blank"}.
- [GlusterFS](https://www.gluster.org/){:target="\_blank"} network storage with the [Kadalu](https://kadalu.github.io/){:target="\_blank"} Kubernetes storage provisioner.

For both you can find the KX.AS.CODE installation scripts at the following locations.

- [Local Storage](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/core/local-storage)
- [Network Storage](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/core/glusterfs-storage)

| Storage Type           | Block Device Name |
|------------------------|-------------------|
| (slow) Network Storage | `/dev/sdc`        |
| (fast) Local Storage   | `/dev/sdb`        |

The local storage drive is installed to all nodes, main and worker. The network storage drive is installed only `to KX-Main1`. This may change in future to install to all provisioned KX-Main nodes.

These drive names tend to hold true for the local virtualization platforms, but may be called something else in AWS or your physical hardware (if installing on Raspberry Pi).

KX.AS.CODE automatically detects the correct drive to use by checking for an unformatted drive's disk size, which should match was either selected in the Jenkins launcher or manually edited in `profile-config.json`. 

!!! danger
    For the virtual solutions (cloud or local) there is no danger in losing any data, as the VMs are coming up with new virtual drives. For a Raspberry Pi setup with mounted physical hardware, it is recommended to either mount new drives and disconnect the ones not relevant for KX.AS.CODE, to avoid accidental loss of data.

    If you already know the disk name for the local storage, you can define it in `profile-config.json` with the `config.local_volumes.diskName` property, and likewise, via the `config.glusterFsDiskName` property for the network storage.  

!!! tip
    For any database workload, you should select the local storage. Not following this pattern may cause the database and associated application not to function in a stable manner.  

When deploying to Kubernetes, to use these storage types, you need to specify the correct storage-class. Here a small table detailing which storage class to specify.

| Storage Type           | Kubernetes Storage Class Name |
|------------------------|----|
| (slow) Network Storage |`kadalu.storage-pool-1` |
| (fast) Local Storage   |`local-storage-sc`|

The local storage class is configured as the default in Kubernetes if the deployment does not specify a preference.