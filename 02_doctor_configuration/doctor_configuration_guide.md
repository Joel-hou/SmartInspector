# Doctor Configuration Guide

## Doctor feature setup in opnfv

- Patch apply
```shell
ansible controller -m script -a "your_path/doctor_configuration.sh" --sudo 
```

- Create datasource for doctor 
On stack VM 
```shell
# overcloud
source overcloudrc
# openstack congress datasource create <datasource driver> <datasource name>
openstack congress datasource create doctor doctor
```

- Add congress policy rule
On stack VM, these policy enable Congress to force down nova compute service when it received a fault event of that compute host. Also, Congress will set the state of all VMs running on that host from ACTIVE to ERROR state

```shell
# overcloud
source overcloudrc

openstack congress policy rule create \
    --name host_down classification \
    'host_down(host) :-
        doctor:events(hostname=host, type="compute.host.down", status="down")'

openstack congress policy rule create \
    --name active_instance_in_host classification \
    'active_instance_in_host(vmid, host) :-
        nova:servers(id=vmid, host_name=host, status="ACTIVE")'

openstack congress policy rule create \
    --name host_force_down classification \
    'execute[nova:services.force_down(host, "nova-compute", "True")] :-
        host_down(host)'

openstack congress policy rule create \
    --name error_vm_states classification \
    'execute[nova:servers.reset_state(vmid, "error")] :-
        host_down(host),
        active_instance_in_host(vmid, host)'
```

- Create alarm
```shell
aodh alarm create --name test_alarm --type event --alarm-action "http://127.0.0.1:12346/" --repeat-actions false --event-type compute.instance.update --query "traits.state=string::error"
```