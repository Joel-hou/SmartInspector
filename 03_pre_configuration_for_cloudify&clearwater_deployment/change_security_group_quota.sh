#!/bin/bash

# this should be executed in all of the controller nodes
# use ansible for your configuration
# ansible controller -m script -a "./change_security_group_quota.sh" --sudo
# already included in preconfig_undercloud.sh

neutronConf="/etc/neutron/neutron.conf"
sudo sed -i "s|^#quota_security_group.*$|quota_security_group = 50|" \
$neutronConf
sudo sed -i "s|^#quota_security_group_rule.*$|quota_security_group_rule = 500|" \
$neutronConf
sudo systemctl restart neutron-server

