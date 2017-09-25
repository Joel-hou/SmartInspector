# Doctor Configuration Guide

## Doctor setup 

- Add congress datasource driver

```shell
co_conf=/etc/congress/congress.conf
co_entry="congress.datasources.doctor_driver.DoctorDriver"

if sudo grep -e "^drivers.*$co_entry" $co_conf; then
    echo "NOTE: congress is configured as we needed"
else
    echo "modify the congress config"
    sudo sed -i -e "/^drivers/s/$/,$co_entry    # added by doctor script/" \
        $co_conf
    sudo systemctl restart openstack-congress-server.service
fi

```
- Create datasource for doctor 

```shell
# openstack congress datasource create <datasource driver> <datasource name>
openstack congress datasource create doctor doctor
```
- Add congress policy rule

```shell
```
- Add notifier topic to Ceilometer
```shell
# add notifier topic 
ep_conf=/etc/ceilometer/event_pipeline.yaml
ep_entry="- notifier://?topic=alarm.all"

if sudo grep -e "$ep_entry" $ep_conf; then
    echo "NOTE: ceilometer is configured as we needed"
else
    echo "modify the ceilometer config"
    sudo sed -i -e "$ a \ \ \ \ \ \ \ \ \ \ $ep_entry    # added by doctor script" $ep_conf
    sudo systemctl restart openstack-ceilometer-notification.service
fi
```
Using ansible
```shell
ansible controller -m script 
```
- Create alarm
```shell

```