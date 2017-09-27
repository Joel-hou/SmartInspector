#!/bin/bash

# on stack VM overcloud, please make sure your environment variable is clean
set -e
source ~/overcloudrc

# configuration for all controller nodes
ansible controller -m script -a "./notification_configuration_controller.sh"

# create doctor datasource
openstack congress datasource create doctor doctor

# function defination
function _congress_add_rule {
    name=$1
    policy=$2
    rule=$3

    if ! openstack congress policy rule list $policy | grep -q -e "// Name: $name$" ; then
        openstack congress policy rule create --name $name $policy "$rule"
    fi
}

function _congress_del_rule {
    name=$1
    policy=$2

    if openstack congress policy rule list $policy | grep -q -e "^// Name: $name$" ; then
        openstack congress policy rule delete $policy $name
    fi
}

function _congress_add_rules {
    _congress_add_rule host_down classification \
        'host_down(host) :-
            doctor:events(hostname=host, type="compute.host.down", status="down")'

    _congress_add_rule active_instance_in_host classification \
        'active_instance_in_host(vmid, host) :-
            nova:servers(id=vmid, host_name=host, status="ACTIVE")'

    #_congress_add_rule host_force_down classification \
        'execute[nova:services.force_down(host, "nova-compute", "True")] :-
            host_down(host)'

    _congress_add_rule pause_vm_states classification \
        'execute[nova:servers.pause(vmid)] :-
            host_down(host),
            active_instance_in_host(vmid, host)'
}

_congress_add_rules
# create alarm
aodh alarm create --name test_alarm --type event --alarm-action "http://127.0.0.1:12346/" --repeat-actions false --event-type compute.instance.update --query "traits.state=string::pause"