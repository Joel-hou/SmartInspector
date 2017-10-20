# OPNFV Deployment Guide via Apex
## Install Apex
```shell
# install dependence
# First setup the build environment
yum groupinstall 'Development Tools'
yum groupinstall 'Virtualization Host'
# The line below installs RDO Ocata for the Euphrates release
yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-ocata/rdo-release-ocata-3.noarch.rpm
yum install -y python2-virtualbmc
# We also need the epel repository
yum install -y epel-release
yum install -y python-devel python-setuptools libguestfs-tools python2-oslo-config python2-debtcollector python-pip openssl-devel bsdtar createrepo
# Needed for overcloud-opendaylight build:
yum install -y libxml2-devel libxslt-devel python34-devel python34-pip
pip3 install gitpython
pip3 install pygerrit2
yum update -y
# reboot make sure changes take effect
reboot
# download necessary package
wget http://artifacts.opnfv.org/apex/dependencies/python34-markupsafe-0.23-9.el7.centos.x86_64.rpm
wget http://artifacts.opnfv.org/apex/dependencies/python3-jinja2-2.8-5.el7.centos.noarch.rpm
wget http://artifacts.opnfv.org/apex/dependencies/python3-ipmi-0.3.0-1.noarch.rpm
yum install -y python34-markupsafe-*.rpm python3-jinja2-*.rpm python3-ipmi-*.rpm
# install apex
cd /home/apex_pack
yum install -y opnfv-apex-5.0-20170705.noarch.rpm opnfv-apex-onos-5.0-20170705.noarch.rpm opnfv-apex-common-5.0-20170705.noarch.rpm opnfv-apex-undercloud-5.0-20170705.noarch.rpm
```
## Deploy OPNFV
> See more details here:http://docs.opnfv.org/en/stable-danube/submodules/apex/docs/release/installation/requirements.html#network-requirements

You had better use screen to avoid accidential disconnection caused by Internet
### Prepare network_settings.yaml file
- Increase admin network dhcp range
Three controller nodes is necessary, if your deployment contains only one controller node, network patch will failed and your soft phone is not able to register to clearwater ellis.

network_settings.yaml
```
...
networks:
  admin:
  ...

  dhcp_range:
    - 192.0.2.2
    - 192.0.2.30
...
```
- External network configuration
installer ip, cidr, gateway, floating ip range and overcloud ip range are modified.
```
...
networks:
  ...
  external:
    - public:
    ...
    installer_vm:
      ...
      ip: 192.168.32.151
    cidr: 192.168.32.128/25
    floating_ip_range:
      - 192.168.32.200
      - 192.168.32.250             # Range to allocate to floating IPs for the public network with Neutron
    overcloud_ip_range:
      - 192.168.32.155
      - 192.168.32.199   
  ...
  external_overlay:
      ....
      gateway: 192.168.32.151
```
Our network_settings file as following:
```yaml

  storage:                           # Storage network configuration
    enabled: true
    cidr: 12.0.0.0/24                # Subnet in CIDR format
    mtu: 1500                        # Storage network MTU
    nic_mapping:                     # Mapping of network configuration for Overcloud Nodes
      compute:                       # Mapping for compute profile (nodes that will be used as Compute nodes)
        phys_type: interface         # Physical interface type (interface or bond)
        vlan: native                 # VLAN tag to use with this NIC
        members:                     # Physical NIC members of this mapping (Single value allowed for interface phys_type)
          - eth3                     # Note, for Apex you may also use the logical nic name (found by nic order), such as "nic1"
      controller:                    # Mapping for controller profile (nodes that will be used as Controller nodes)
        phys_type: interface
        vlan: native
        members:
          - eth3
                                     #
  api:                               # API network configuration
    enabled: false
    cidr: fd00:fd00:fd00:4000::/64   # Subnet in CIDR format
    vlan: 13                         # VLAN tag to use for Overcloud hosts on this network
    mtu: 1500                        # Api network MTU
    nic_mapping:                     # Mapping of network configuration for Overcloud Nodes
      compute:                       # Mapping for compute profile (nodes that will be used as Compute nodes)
        phys_type: interface         # Physical interface type (interface or bond)
        vlan: native                 # VLAN tag to use with this NIC
        members:                     # Physical NIC members of this mapping (Single value allowed for interface phys_type)
          - eth4                     # Note, for Apex you may also use the logical nic name (found by nic order), such as "nic1"
      controller:                    # Mapping for controller profile (nodes that will be used as Controller nodes)
        phys_type: interface
        vlan: native
        members:
          - eth4

# Apex specific settings
apex:
  networks:
    admin:
      introspection_range:
        - 192.0.2.150
        - 192.0.2.220                # Range used for introspection phase (examining nodes).  This cannot overlap with dhcp_range or overcloud_ip_range.
                                     # If the external network 'public' is disabled, then this range will be re-used to configure the floating ip range
                                     # for the overcloud default external network
"network_settings.yaml" 220L, 12249C                                                                                                                         218,38        Bot
# This configuration file defines Network Environment for a
# Baremetal Deployment of OPNFV. It contains default values
# for 5 following networks:
#
# - admin
# - tenant*
# - external*
# - storage*
# - api*
# *) optional networks
#
# Optional networks will be consolidated with the admin network
# if not explicitly configured.
#
# See short description of the networks in the comments below.
#
# "admin" is the short name for Control Plane Network.
# This network should be IPv4 even it is an IPv6 deployment
# IPv6 does not have PXE boot support.
# During OPNFV deployment it is used for node provisioning which will require
# PXE booting as well as running a DHCP server on this network.  Be sure to
# disable any other DHCP/TFTP server on this network.
#
# "tenant" is the network used for tenant traffic.
#
# "external" is the network which should have internet or external
# connectivity.  External OpenStack networks will be configured to egress this
# network.  There can be multiple external networks, but only one assigned as
# "public" which OpenStack public API's will register.
#
# "storage" is the network for storage I/O.
#
# "api" is an optional network for splitting out OpenStack service API
# communication.  This should be used for IPv6 deployments.


#Meta data for the network configuration
network-config-metadata:
  title: LF-POD-1 Network config
  version: 0.1
  created: Mon Dec 28 2015
  comment: None
                                                                                                                                                             1,1           Top
  storage:                           # Storage network configuration
    enabled: true
    cidr: 12.0.0.0/24                # Subnet in CIDR format
    mtu: 1500                        # Storage network MTU
    nic_mapping:                     # Mapping of network configuration for Overcloud Nodes
      compute:                       # Mapping for compute profile (nodes that will be used as Compute nodes)
        phys_type: interface         # Physical interface type (interface or bond)
        vlan: native                 # VLAN tag to use with this NIC
        members:                     # Physical NIC members of this mapping (Single value allowed for interface phys_type)
          - eth3                     # Note, for Apex you may also use the logical nic name (found by nic order), such as "nic1"
      controller:                    # Mapping for controller profile (nodes that will be used as Controller nodes)
        phys_type: interface
        vlan: native
        members:
          - eth3
                                     #
  api:                               # API network configuration
    enabled: false
    cidr: fd00:fd00:fd00:4000::/64   # Subnet in CIDR format
    vlan: 13                         # VLAN tag to use for Overcloud hosts on this network
    mtu: 1500                        # Api network MTU
    nic_mapping:                     # Mapping of network configuration for Overcloud Nodes
      compute:                       # Mapping for compute profile (nodes that will be used as Compute nodes)
        phys_type: interface         # Physical interface type (interface or bond)
        vlan: native                 # VLAN tag to use with this NIC
        members:                     # Physical NIC members of this mapping (Single value allowed for interface phys_type)
          - eth4                     # Note, for Apex you may also use the logical nic name (found by nic order), such as "nic1"
      controller:                    # Mapping for controller profile (nodes that will be used as Controller nodes)
        phys_type: interface
        vlan: native
        members:
          - eth4

# Apex specific settings
apex:
  networks:
    admin:
      introspection_range:
        - 192.0.2.150
        - 192.0.2.220                # Range used for introspection phase (examining nodes).  This cannot overlap with dhcp_range or overcloud_ip_range.
                                     # If the external network 'public' is disabled, then this range will be re-used to configure the floating ip range
                                     # for the overcloud default external network
```
OPNFV deployment
```shell
opnfv-clean
cd /etc/opnfv-apex/
opnfv-deploy -v --virtual-cpus 8  --virtual-default-ram 64 --virtual-computes 4 -n network_settings.yaml -d os-nosdn-nofeature-ha.yaml --debug > apex.log
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

Example: one controller node (for configuration convenience, noha), four compute nodes
```shell
opnfv-deploy -v --virtual-cpus 8  --virtual-default-ram 64 --virtual-computes 4 -n network_settings.yaml -d os-nosdn-nofeature-ha.yaml --debug > apex.log
```
Note: 

Under this condition, openstack external network cann't be directly accessed from outside. OPNFV Apex installer requires no dhcp server exists on openstack external network during deployment otherwise deployment will fail. On the other side, we need to make openstack external network accessible from outside in order to do vIMS test. Our solution is changing network configuration on controller and compute nodes after OPNFV fully deployment to make openstack external network accessible directly(By default, openstack external network is NAT to undercloud since we use virtual deployment), and one controller node is NOT going to work(openstack-nova-compute process fails after you change network configuration file), use 3 controller nodes instead.

Trouble shooting:

- Stack failed because no fixed ip avaliable
```
# edit network_settings.yaml
# increase admin network dhcp_range 
# example:
dhcp_range:
      - 192.0.2.2
      - 192.0.2.30
# should be enough for 3 controller nodes and 4 compute nodes deployment
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
ansible-playbook opnfv_direct_internet_access_network_configuration_compute.yml
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
