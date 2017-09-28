# Live migrate config guide

NFS configuration should be done before any of your VM booted, otherwise VM booted before NFS configuration will not be able to be live-migrated

- Controller node
```shell
ansible controller -m script -a "./config_live_migrate_controller.sh" --sudo
```
- Compute node
```shell
ansible compute -m script -a "./config_live_migrate_compute.sh your_nfs_server_ip" --sudo
```