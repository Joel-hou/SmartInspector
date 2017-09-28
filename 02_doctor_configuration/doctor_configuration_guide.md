# Doctor Configuration Guide

## Doctor feature setup in opnfv
```shell
sudo chmod +x doctor_configuration.sh
./doctor_configuration.sh
```
## Remove doctor feature patch
```shell
# please make sure 
# source ~/overcloudrc before

# remove alarm
aodh alarm delete test_alarm

# delete congress policy
openstack congress policy rule delete classification pause_vm_states
openstack congress policy rule delete classification active_instance_in_host 
openstack congress policy rule delete classification host_down

# delete congress datasource
openstack congress datasource delete doctor
```