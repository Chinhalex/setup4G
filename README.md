Excersise Description
Write a script file to setup OAI Core 4G components automatically 

I. Manual Guide: https://github.com/OPENAIRINTERFACE/openair-epc-fed/blob/master/docs/DEPLOY_PRE_REQUESITES_MAGMA.md

II. Step by step

1. Check OS version. If OS version != Ubuntu 18.04 --> log ERROR & exit
$   lsb_release -d
2. Install docker
$ dpkg --list | grep docker
$ sudo usermod -a -G docker myusername
/// myusername is current account
3. Install a recent version of docker-compose

4. Pull base images
4.1 Account Login 
$docker login

4.2 Pull images
$ docker pull ubuntu:bionic
$ docker pull cassandra:2.1
$ docker pull redis:6.0.5

5. Setup Network
$ sudo sysctl net.ipv4.conf.all.forwarding=1
$ sudo iptables -P FORWARD ACCEPT


6. Create new file /etc/docker/daemon.json file:
{
	"bip": "192.168.17.1/24"
}

7. Restart docker

$ sudo service docker restart


8. Pulling the images from Docker Hub

$ docker pull rdefosseoai/oai-hss:latest
$ docker pull rdefosseoai/oai-spgwc:latest
$ docker pull rdefosseoai/oai-spgwu-tiny:latest
$ docker pull rdefosseoai/magma-mme:latest

$ docker image tag rdefosseoai/oai-hss:latest oai-hss:production
$ docker image tag rdefosseoai/oai-spgwc:latest oai-spgwc:production
$ docker image tag rdefosseoai/oai-spgwu-tiny:latest oai-spgwu-tiny:production
$ docker image tag rdefosseoai/magma-mme:latest magma-mme:master

9. Clone oai epc-fed 

$ git clone --branch v1.2.0 https://github.com/OPENAIRINTERFACE/openair-epc-fed.git
$ cd openair-epc-fed
// If you forgot to clone directly to the latest release tag
$ git checkout -f v1.2.0

// Synchronize all git submodules
$ ./scripts/syncComponents.sh


10. Initialize the Cassandra DB

$ cd docker-compose/magma-mme-demo
$ docker-compose up -d db_init

==> delay 5s for next command
$ docker logs demo-db-init --follow
$ docker rm -f demo-db-init
$ docker logs demo-cassandra


11. Deploy all EPC

$ docker-compose up -d oai_spgwu

Wait 10s

