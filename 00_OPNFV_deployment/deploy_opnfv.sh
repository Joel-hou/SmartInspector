#!/bin/bash
# on jumphost 
# HW: 4 core/E7-8890-v3 512G RAM
# to deploy opnfv via Apex

# NAT virbr0 to br-external, so VMs on undercloud can access Internet 
sysctl net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -j SNAT --to 192.168.32.20
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

opnfv-clean
cd /etc/opnfv-apex 
opnfv-deploy -v --virtual-cpus 8  --virtual-default-ram 64 --virtual-computes 4 -n network_settings.yaml -d os-nosdn-nofeature-ha.yaml --debug > apex.log 