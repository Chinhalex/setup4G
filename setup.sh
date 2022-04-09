#!/bin/sh

#1.Check version of ubuntu 18.04
if [ "$(lsb_release -ds)" != "Ubuntu 18.04.6 LTS" ]
then
	echo "ERROR & EXIT"
	echo "Thank you!!!"
	exit 1
fi

sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker ${USER}
echo "###################################################################################"
echo "#1.Install docker                                                                 #"
echo "#OS is identified as Ubuntu 18.04                                                 #"
echo "# This Script will remove old docker components and install latest stable docker  #"
echo "###################################################################################"
sleep 1

echo "==> Removing older version of docker if any...."
sudo apt-get remove docker docker-engine docker.io containerd runc -y 2>/dev/null

echo "==> Updating exiting list of packagesss..."
sudo apt update -y

echo "==> Installing dependencies......."
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

echo "==> Adding the GPG key for the official Docker repository to your system..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "==> Adding the Docker repository to sudo apt sources:.."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y

echo "==> Now Installing Docker ...."
sudo apt install docker-ce docker-ce-cli -y

if [ $? -ne 0]
then
	echo "====>  Sorry Failed to install Docker. Try it manually  <===="
	exit 2
fi


echo "====>  Docker has been installed successfully on this host - $(hostname -s)  <===="
if systemctl status docker &>/dev/null 
then
	echo "====>  And it is up and running... You can verify it using cmd: systemctl status docker  <===="
else
	echo "====>  But it is not running. You can start it manually using cmd: systemctl start docker  <===="
fi

echo "# Docker Engine Version is: $(docker --version | cut -d " " -f3 | tr -d ",") #"

echo "###################################################################################"
echo "3. Now install a recent version of docker-compose                                 #"
echo "###################################################################################"
sleep 1

echo "Now choise y/n: "
read choose
case $choose in
    y | Y | yes | Yes ) 
                        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                        sudo chmod +x /usr/local/bin/docker-compose
                        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
                        docker-compose --version 
                        ;;
    n | N | no | No   )
                        echo $(docker-compose --version)
                        ;;
                     *)
                        echo "don\'t know"
                        ;;
esac

echo "###################################################################################"
echo "4. Now Pull base images                                                           #"
echo "###################################################################################"
sleep 2

echo "Do you have a account ? Now choise y/n: "
read choose1
case $choose1 in
    y | Y | yes | Yes ) 
                        docker login 
                        ;;
    n | N | no | No   )
                        echo "Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one."
                        docker login
                        ;;
                     *)
                        echo "don\'t know"
                        exit 2
                        ;;
esac

echo "###################################################################################"
echo "4.2. Now Pull images                                                              #"
echo "###################################################################################"
sleep 2

echo "Do you wana now pull images  ? Now choise y/n: "
read choose2
case $choose2 in
    y | Y | yes | Yes ) 
                        docker pull ubuntu:bionic
                        docker pull cassandra:2.1
                        docker pull redis:6.0.5
                        ;;
    n | N | no | No   )
                        echo "exit and logout"
                        docker logout
                        exit 2
                        ;;
                     *)
                        echo "don\'t know"
                        exit 2
                        ;;
esac



echo "###################################################################################"
echo "5.Setup Network                                                                   #"
echo "###################################################################################"
sleep 2
echo "Do you wana now setup network  ? Now choise y/n: "
read choose3
case $choose2 in
    y | Y | yes | Yes ) 
                        sudo sysctl net.ipv4.conf.all.forwarding=1
                        sudo iptables -P FORWARD ACCEPT
                        ;;
    n | N | no | No   )
                        echo "exit and logout"
                        docker logout
                        exit 2
                        ;;
                     *)
                        echo "don\'t know"
                        exit 2
                        ;;
esac

echo "###################################################################################"
echo "6.Create new file /etc/docker/daemon.json file:                                   #"
echo "###################################################################################"
cat $(pwd)/daemon.json | sudo tee -p /etc/docker/daemon.json


echo "###################################################################################"
echo "7.Restart docker                                                                  #"
echo "###################################################################################"

sudo service docker restart

echo "###################################################################################"
echo "8.Pulling the images from Docker Hub                                              #"
echo "###################################################################################"
sleep 2

docker pull rdefosseoai/oai-hss:latest
docker pull rdefosseoai/oai-spgwc:latest
docker pull rdefosseoai/oai-spgwu-tiny:latest
docker pull rdefosseoai/magma-mme:latest
docker image tag rdefosseoai/oai-hss:latest oai-hss:production
docker image tag rdefosseoai/oai-spgwc:latest oai-spgwc:production
docker image tag rdefosseoai/oai-spgwu-tiny:latest oai-spgwu-tiny:production
docker image tag rdefosseoai/oai-spgwu-tiny:latest oai-spgwu-tiny:producti
docker image tag rdefosseoai/magma-mme:latest magma-mme:master

echo "###################################################################################"
echo "9. Clone oai epc-fed                                                              #"
echo "###################################################################################"
sleep 2

git clone --branch v1.2.0 https://github.com/OPENAIRINTERFACE/openair-epc-fed.git
cd openair-epc-fed
# If you forgot to clone directly to the latest release tag
git checkout -f v1.2.0
# Synchronize all git submodules
./scripts/syncComponents.sh

echo "###################################################################################"
echo "10.Initialize the Cassandra DB                                                     #"
echo "###################################################################################"
sleep 2

cd docker-compose/magma-mme-demo
docker-compose up -d db_init

sleep 5

docker logs demo-db-init --follow
docker rm -f demo-db-init
docker logs demo-cassandra


echo "###################################################################################"
echo "11.Deploy all EPC                                                                 #"
echo "###################################################################################"
sleep 2

docker-compose up -d oai_spgwu
sleep 10
