#!/bin/bash

# add ceilometer notifier topic 



# add user defined publisher of topic previous defined 
# ep means event_pipeline
ep_conf=/etc/ceilometer/event_pipeline.yaml
ep_entry="- notifier://?topic=alarm.all"

if sudo grep -e "$ep_entry" $ep_conf; then
    echo "NOTE: ceilometer is configured as we needed"
else
    echo "modify the ceilometer config"
    sudo sed -i -e "$ a \ \ \ \ \ \ \ \ \ \ $ep_entry" $ep_conf
    sudo systemctl restart openstack-ceilometer-notification.service
fi

# add congress datasource driver
co_conf=/etc/congress/congress.conf
co_entry="congress.datasources.doctor_driver.DoctorDriver"

if sudo grep -e "^drivers.*$co_entry" $co_conf; then
    echo "NOTE: congress is configured as we needed"
else
    echo "modify the congress config"
    sudo sed -i -e "/^drivers/s/$/,$co_entry" \
        $co_conf
    sudo systemctl restart openstack-congress-server.service
fi
