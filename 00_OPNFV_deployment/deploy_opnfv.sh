#!/bin/bash
# on HW server
# to deploy opnfv via Apex

# HW: 4 core/E7-8890-v3 512G RAM
opnfv-clean
cd /etc/opnfv-apex 
screen -S apex_deploy_screen \
	opnfv-deploy -v --virtual-cpus 8 \
    --virtual-default-ram 64 --virtual-compute-ram 96 \
    -n network_settings.yaml -d os-nosdn-nofeature-ha.yaml --debug > apex.log