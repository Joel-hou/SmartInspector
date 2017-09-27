#!/bin/bash

# add ceilometer notifier topic 
ce_conf=/etc/ceilometer/ceilometer.conf
ce_entry="event_topic = event"
if sudo grep -e "^$ce_entry$" $ce_conf; then
    echo "NOTE: ceilometer.conf is configured as we needed"
else
    echo "modify the ceilometer.conf "
    sudo sed -e "s|^#event_topic = event$|event_topic = event|" $ce_conf > world
fi

# add user defined publisher of topic previous defined 
## ep means event_pipeline
ep_conf=/etc/ceilometer/event_pipeline.yaml
ep_entry="- notifier://?topic=alarm.all"

if sudo grep -e "$ep_entry" $ep_conf; then
    echo "NOTE: ceilometer event_pipeline is configured as we needed"
else
    echo "modify the ceilometer event_pipeline config"
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
