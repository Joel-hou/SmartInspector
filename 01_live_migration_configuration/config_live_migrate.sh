#!/bin/bash
# please make sure your environment is clean
source ~/stackrc
controller-0-ip=$(nova list | grep overcloud-controller-0 | cut -d'|' -f 7 | cut -d'=' -f 2)
# install nfs-server on controller-0
ansible controller-0 -m script -a "config_live_migrate_controller.sh" --sudo

# install nfs-client on all compute node 
ansible compute -m script -a "./config_live_migrate_compute.sh $controller-0-ip" --sudo