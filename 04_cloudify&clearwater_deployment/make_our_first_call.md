# Make our first call

## Clearwater live test 
We run the clearwater live test in cloudify CLI VM via docker, all necessary tests passed from live test results, but we are not sure does that mean all function of our clearwater deployment are worked properly, it seems that live test just do some registering and dialing test instead of talking on the soft phone, voice on the soft phone should not be interrupted if everything works, which doesn't involved in live test.

## Soft phone call test

### ISP client configuration

#### X-Lite
##### Account tab
Proxy Address: < your clearwater bono ip >
##### Advance tab
Force outbound proxy on all requests: you should have this checked
##### Topology tab
Firewall traversal method: None

#### Blink
##### Server settings tab
Outbound Proxy: < your clearwater bono ip >

### ISP client test result
We have three windows VMs and get X-Lite installed
- 172.16.10.8
- 172.16.10.11
- 172.16.10.22

Both 10.8 and 10.22 failed to register to clearwater via tcp, but udp worked. but 10.11 could register successful to clearwater via tcp.

[X-Lite udp] 172.16.10.8 -------✓-------> [X-Lite tcp] 172.16.10.22

Other combinations

[X-Lite udp/tcp] 172.16.10.8 -------×-------> [X-Lite udp] 172.16.10.22

## Problems remaining 
Our openstack external network is 192.168.32.0/24, we use cloudify to deploy clearwater. Some VM has been associated with  floating ips (eg. ellis) 192.168.32.x which could be visited through VPN from our local laptop (ip address assigned by VPN is 10.x.x.x), VPN is a kind of NAT device, We have tried several ISP clients (X-Lite, Jitsi and Blink) on our local laptop but none of them worked perfectly. Two Blink clients could establish initial connection successfully but failed with "no ack arrived" after a few seconds(about 15s), since we don't know any details about ISP protocal and the VPN we used, we are not sure about if NAT tranverse method of our ISP client worked successfuly for the VPN. We do all of our following tests on windows VMs which are on the 172.16.10.x/24 network, so the connection between those two ISP clients won't get involved with NAT, but one of our client failed register via tcp to ellis, the other worked. These windows VMs are supposed to have all the same environment.

