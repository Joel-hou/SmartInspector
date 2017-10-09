# OPNFV Deployment Guide via Apex
## Deploy OPNFV
Note: you cann't edit network_settings.yaml file directly then execute opnfv deploy command, cause there should not be any dhcp server on the network used by OPNFV which may be not satisfied
> See more details here:http://docs.opnfv.org/en/stable-danube/submodules/apex/docs/release/installation/requirements.html#network-requirements

you had better use screen to avoid accidential disconnection caused by Internet
```shell
opnfv-clean
cd /etc/opnfv-apex/
opnfv-deploy -v --virtual-cpus 8 --virtual-default-ram 64 --virtual-compute-ram 96 -n network_settings.yaml -d os-nosdn-nofeature-ha.yaml --debug
```
other optional parameters:
-   --deploy-settings | -d : Full path to deploy settings yaml file. Optional.  Defaults to null
-   --inventory | -i : Full path to inventory yaml file. Required only for baremetal
-   --net-settings | -n : Full path to network settings file. Optional.
-   --ping-site | -p : site to use to verify IP connectivity. Optional. Defaults to 8.8.8.8
-   --dnslookup-site : site to use to verify DNS resolution. Optional. Defaults to www.google.com
-   --virtual | -v : Virtualize overcloud nodes instead of using baremetal.
-   --no-post-config : disable Post Install configuration.
-   --debug : enable debug output.
-   --interactive : enable interactive deployment mode which requires user to confirm steps of deployment.
-   --virtual-cpus : Number of CPUs to use per Overcloud VM in a virtual deployment (defaults to 4).
-   --virtual-computes : Number of Virtual Compute nodes to create and use during deployment (defaults to 1 for noha and 2 for ha).
-   --virtual-default-ram : Amount of default RAM to use per Overcloud VM in GB (defaults to 8).
-   --virtual-compute-ram : Amount of RAM to use per Overcloud Compute VM in GB (defaults to 8). Overrides --virtual-default-ram arg for computes

Example: one controller node (for POC convenience, noha), four compute nodes
```shell
 opnfv-deploy -v --virtual-cpus 16 --virtual-default-ram 64 --virtual-compute-ram 96 --virtual-computes 4 -n network_settings.yaml -d os-nosdn-nofeature-noha.yaml --debug > apex.log
```
## Network configuration via Ansible 
Make sure you hosts file was configured properly and you had better disable ssh hosts key checking to avoid further annnoying

Disable ssh host key checking:
```shell
sudo vim /etc/ansible/ansible.cfg
```
then uncomment host_key_checking = False

Check if your ansible hosts file was configured properly
```shell
ansible controller -m ping 
```
```shell
ansible compute -m ping
```
You should see all green output, you had better disable ansible SSH key host checking for better experience

Firstly make sure your controller and compute nodes ip configuration is correct
### Controller nodes configuration (in your stack machine/ansible host machine)
```shell
ansible-playbook opnfv_direct_internet_access_network_configuration_controller.yml
```
### Compute nodes configuration (in your stack machine/ansible host machine)
Make sure the ip which is on the same network with your Jumphost network dev is eth2 before execute this command
```shell
ansible_playbook opnfv_direct_internet_access_network_configuration_compute.yml
```
If everything works fine, you should see all green output

## Manual network configuration 
Find your compute nodes and controller nodes ip
```shell
opnfv-util-undercloud 
source stackrc
nova list
```
Network configuration is needed in all nodes

```shell
ssh heat-admin@192.0.2.x
```
### On controller nodes
```shell
sudo -i
vim /etc/sysconfig/network-scripts/ifcfg-br-ex
```
change netmask to 255.255.255.0
```shell
vim /etc/sysconfig/network-scripts/route-br-ex
```
change default gateway to 192.168.32.1, you can see something like 'default via 192.168.32.1'
### On compute nodes
Firstly 'route -n' to find out interface associated with 192.168.32.x ip address, then edit ifcfg-xxx and route-xxx file
## Last step
You may need to delete the subnet of default external network and creat a new one because it's network mask generated during Apex installing process is /25,netmask should be /24 during our installation process. You can do it manauly via OpenStack dashboard or by OpenStack commands
```shell
source ~/overcloudrc
# delete external default subnet
neutron subnet-delete external-net 
# recreate external subnet
neutron subnet-create external 192.168.32.0/24  --name  external-net --dns-nameserver 8.8.8.8 --gateway 192.168.32.1 --allocation-pool start=192.168.32.191,end=192.168.32.250  
```

