#!/bin/bash

# on stack VM overcloud, please make sure your environment variable is clean
set -e
source ~/overcloudrc

# notification configuration is not necessary for our s2(solution 2)
# let congress do automatic fault recovery job

# create doctor datasource
openstack congress datasource create doctor doctor

# add policy
openstack congress policy rule create \
    --name host_down classification \
        'host_down(host) :-
        doctor:events(hostname=host, type="compute.host.down", status="down")'

openstack congress policy rule create \
    --name active_instance_in_host classification \
    'active_instance_in_host(vmid, host) :-
        nova:servers(id=vmid, host_name=host, status="ACTIVE")'

# make compute 3 node as our fault recovery default node
openstack congress policy rule create \
    --name live_migrate_vm classification \
    'execute[nova:servers.live_migrate(vmid,"overcloud-novacompute-3.opnfvlf.org","False","False")] :-
        host_down(host),
        active_instance_in_host(vmid, host)'
