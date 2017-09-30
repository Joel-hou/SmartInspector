# Run clearwater live test on cloudify cli VM 
After your clearwater deployment, you should run clearwater live test once your deployment is finished to make sure your depoyment  works properly

On your cloudify CLI VM, we use opnfv/functest container because all dependancies are already installed in docker image

- install docker
```shell
# install docker on this VM before any operation
curl -sSL https://get.docker.com/ | sh
sudo usermod -a -G docker $USER
# log out of your account and back log in
```
- run clearwater live test
```shell
# download opnfv docker image
docker pull opnfv/functest:danube.3.0
# run the docker container
# dns will be your bono ip address on your clearwater deployment
docker run --dns=192.168.32.199 -it opnfv/functest:danube.3.0 /bin/bash
# launch the test
cd ~/repos/vnfs/vims-test
source /etc/profile.d/rvm.sh
rake test[clearwater.opnfv] SIGNUP_CODE=secret
# after this,you should be able to see the test results no console
```