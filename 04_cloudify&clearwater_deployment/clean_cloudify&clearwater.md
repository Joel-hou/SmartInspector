# Clean cloudify&clearwater deployment

If error occurs with cloudify or clearwater, such cloudify execution can not be stopped, or user can not registered to clearwater, you may need to clean your environment and deoploy cloudify and clearwater again
- delete all VMs except cloudify CLI VM
- delete all security groups except default
- delete security key of agent and manager from openstack dashboard
- release all floating ip except the one assigned to cloudify CLI VM
- clear gateway of cloudify management network (Project->Network->Router)
- delete interfaces (Project->Network->Router->Interface) 
- delete subnet of cloudify management network 
- delete cloudify management network
- on cloudify ClI VM : rm -rf cloudify
```shell
rm -rf ~/cloudify
rm ~/.ssh/cloudify-manager-kp.pem
rm ~/.ssh/cloudify-agent-kp.pem
```
