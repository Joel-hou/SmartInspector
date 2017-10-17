#!/bin/bash

# on stack VM overcloud, please make sure your environment variable is clean
set -e
source ~/overcloudrc

# configuration for all controller nodes
ansible controller -m script -a "./notification_configuration_controller.sh" --sudo

# create doctor datasource
openstack congress datasource create doctor doctor

# add policy
# xuan xue:Syntax error for rule::Literal doctor:events(hostname=host, status="down", type="compute.host.down") uses named arguments, but the schema is unknown.
# the following line should work
openstack congress policy rule create     --name host_down classification     'host_down(host) :-
        doctor:events(hostname=host, type="compute.host.down", status="down")'

openstack congress policy rule create \
    --name active_instance_in_host classification \
    'active_instance_in_host(vmid, host) :-
        nova:servers(id=vmid, host_name=host, status="ACTIVE")'

openstack congress policy rule create \
    --name pause_vm_states classification \
    'execute[nova:servers.pause(vmid)] :-
        host_down(host),
        active_instance_in_host(vmid, host)'

# create alarm
aodh alarm create --name test_alarm --type event --alarm-action "http://127.0.0.1:12346/" --repeat-actions false --event-type compute.instance.update --query "traits.state=string::paused"