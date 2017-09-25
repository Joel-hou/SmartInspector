#!/bin/bash

# network configuration for opnfv installed via apex
ansible-playbook network_configuration_controller.yml
ansible-playbook network_configuration_compute.yml

# modify default external network
source ~/overcloudrc
# delete external default subnet
neutron subnet-delete external-net 
# recreate external subnet
neutron subnet-create external 192.168.32.0/24  --name  external-net --dns-nameserver 8.8.8.8 --gateway 192.168.32.1 --allocation-pool start=192.168.32.191,end=192.168.32.250
