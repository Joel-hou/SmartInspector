# OpenStack instruction
## Nova

### Restart nova service after modify nvoa.conf
Restart controller nodes
```shell
ansible controller -m shell -a "service openstack-nova-api restart && service openstack-nova-cert restart && service openstack-consoleauth restart && service openstack-nova-scheduler restart && service openstack-nova-conductor restart && service openstack-nova-noncproxy restart" --sudo
```
Restart compute nodes
```shell
ansible compute -m shell -a "service openstack-nova-compute restart" --sudo 
```

### Unpause VM
```shell
nova unpause server_name_or_id
```
### Boot VM on specific compute node
Firstly, list all of your avaliable zone
```shell
nova hypervisor-list
```
Boot VM
```shell
nova boot --flavor 4 --image 7ebd2a4b-437f-4017-83b5-0f054149a540 --key-name newbie_test --availability-zone nova:overcloud-novacompute-2.opnfvlf.org your_VM_name
```
### Reset compute node state 
```shell
nova service-force-down --unset overcloud-novacompute-0.opnfvlf.org nova-compute
```
This will set compute node state from down to up
### Reset VM state
```shell
nova reset-state --active a7614957-0674-4898-833f-0251059f5f3b
```
This will set VM state from error to active

## Neutron

Show detailed information of external-net subnet
```shell
neutron subnet-show external-net
```
- Delete subnet
```shell
neutron subnet-delete external-net 
```
- Create new subnet
```shell
neutron subnet-create external 192.168.32.0/24  --name  external-net --dns-nameserver 8.8.8.8 --gateway 192.168.32.1 --allocation-pool start=192.168.32.191,end=192.168.32.250  
```

## Aodh

### Alarm create
```shell
aodh alarm create --name test_alarm --type event --alarm-action "http://127.0.0.1:12346/" --repeat-actions false --event-type compute.instance.update --query "traits.state=string::error"
```
### Delete alarm 
```shell
aodh alarm delete test_alarm 
```
### Show alarm 
```shell
aodh alarm list
```
### Show alarm history
```shell
aodh alarm-history show test_alarm 
```
### Get alarm state
```shell
alarm state get test_alarm 
```
### Set alarm state
```shell
aodh alarm state set --state ok test_alarm   
```

## Ceilometer

### Alarm list
```shell
ceilometer alarm-list
```
### Alarm delete
```shell
ceilometer alarm-delete  5cb446ae-20a9-4010-bda0-3d403ccf6200
```
### Restart ceilometer
```shell
service  openstack-ceilometer-api  restart    
service openstack-ceilometer-notification restart
service openstack-ceilometer-central  restart
service openstack-ceilometer-collector  restart
```

## Congress

### Create policy rule
```shell
openstack congress policy rule create \
    --name host_down classification \
    'host_down(host) :-
        doctor:events(hostname=host, type="compute.host.down", status="down")'
```
### Delete policy rule
```shell
openstack congress policy rule delete classification host_down
```

## Celiometer

### Restart ceilometer
controller nodes
```shell
service  openstack-ceilometer-api  restart    
service openstack-ceilometer-notification restart
service openstack-ceilometer-central  restart
service openstack-ceilometer-collector  restart
```

## Other useful tips  
- Get token from keystone
```shell
curl -H "Content-Type: application/json" -X POST -d '
{
    "auth": {
        "tenantName": "admin",
        "passwordCredentials": {
            "username": "admin",
            "password": "ngn2s6cpAeZn7cgnNyHzcE4Cf"
        }
    }
}
' http://192.168.32.163:35357/v2.0/tokens \
  | python -m json.tool
```

- Migrate VM via curl restful API 
```shell
curl -g -i -X POST http://192.168.32.163:8774/v2.1/servers/75fc72f8-52f0-49dd-a2f4-80b81953924a/action \
    -H "Accept: application/json" -H "User-Agent: python-novaclient" -H "OpenStack-API-Version: compute 2.34" \
    -H "X-OpenStack-Nova-API-Version: 2.34" \
    -H "X-Auth-Token: $OS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"os-migrateLive": {"block_migration": "False", "host": "overcloud-novacompute-1.opnfvlf.org", "force": "True"}}'
```
