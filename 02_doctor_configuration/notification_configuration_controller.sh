#!/bin/bash

# add congress datasource driver
co_conf=/etc/congress/congress.conf
co_entry="congress.datasources.doctor_driver.DoctorDriver"

if sudo grep -e "^drivers.*$co_entry" $co_conf; then
    echo "NOTE: congress is configured as we needed"
else
    echo "modify the congress config"
    sudo sed -i -e "/^drivers/s/$/,$co_entry/" \
        $co_conf
    sudo systemctl restart openstack-congress-server.service
fi

# add user defined publisher of topic event
## ep means event_pipeline
ep_conf=/etc/ceilometer/event_pipeline.yaml
ep_entry="- notifier://?topic=alarm.all"

if sudo grep -e "$ep_entry" $ep_conf; then
    echo "NOTE: ceilometer event_pipeline is configured as we needed"
else
    echo "modify the ceilometer event_pipeline.yaml"
    sudo sed -i -e "$ a \ \ \ \ \ \ \ \ \ \ $ep_entry" $ep_conf
    sudo systemctl restart openstack-ceilometer-notification.service
fi

# add ceilometer notifier topic 
ce_conf=/etc/ceilometer/ceilometer.conf
ce_entry="event_topic = event"
if sudo grep -e "^$ce_entry$" $ce_conf; then
    echo "NOTE: ceilometer.conf is configured as we needed"
else
    echo "modify ceilometer.conf "
    sudo sed -i -e "s|^#event_topic = event$|event_topic = event|" $ce_conf
    sudo service openstack-ceilometer-notification restart
    sudo service openstack-ceilometer-central restart
fi

# nova configuration for notification
no_conf=/etc/nova/nova.conf
no_entry="topics=notifications"
if sudo grep -e "$no_entry" $no_conf; then
    echo "NOTE: nova.conf is configured as we needed"
else
    echo "modify nova.conf"
    sudo sed -i '/driver=messagingv2/atopics=notifications' $no_conf
    sudo service openstack-nova-api restart 
    sudo service openstack-nova-cert restart 
    sudo service openstack-nova-consoleauth restart
    sudo service openstack-nova-scheduler restart
    sudo service openstack-nova-conductor restart
    sudo service openstack-nova-novncproxy restart
fi

# aoch configuration 
ao_conf=/etc/aodh/aodh.conf
ao_entry="event_alarm_topic = alarm.all"

if sudo grep -e "^$ao_entry" $ao_conf; then
    echo "NOTE: aodh.conf is configured as we needed"
else
    echo "modify aodh.conf"
    sudo sed -i -e "s|^#event_alarm_topic = alarm.all$|event_alarm_topic = alarm.all|" $ao_conf
    sudo service openstack-aodh-listener restart
    sudo service openstack-aodh-notifier restart
fi

