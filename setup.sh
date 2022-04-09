#!/bin/sh

sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker ${USER}
#Check version of ubuntu 18.04
if [ "$(lsb_release -ds)" != "Ubuntu 18.04.6 LTS" ]
then
	echo "ERROR & EXIT"
	echo "Thank you!!!"
	exit 1
fi

# install ubuntu 18.04 
echo "###################################################################################"
echo "# OS is identified as Ubuntu                                                      #"
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
# if systemctl status docker &>/dev/null 
# then
# 	echo "====>  And it is up and running... You can verify it using cmd: systemctl status docker  <===="
# else
# 	echo "====>  But it is not running. You can start it manually using cmd: systemctl start docker  <===="
# fi

# << comment
# echo "#############################################"
# echo "# Now, You can play with docker             #"
# echo "# Docker Info on $(hostname -s) is: #"
# echo "# Docker Engine Version is: $(docker --version | cut -d " " -f3 | tr -d ",") #"
# echo "#############################################"
# comment

echo "###################################################################################"
echo "Now install a recent version of docker-compose                                    #"
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
echo "Now Pull base images                                                              #"
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
                        ;;
esac

echo "###################################################################################"
echo "Now Pull images                                                              #"
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
                        ;;
esac



echo "###################################################################################"
echo "Setup Network                                                                     #"
echo "###################################################################################"
sleep 2
echo "Do you wana now setup network  ? Now choise y/n: "
read choose3
case $choose2 in
    y | Y | yes | Yes ) 
                        sudo sysctl net.ipv4.conf.all.forwarding=1
                        ;;
    n | N | no | No   )
                        echo "exit and logout"
                        docker logout
                        exit 2
                        ;;
                     *)
                        echo "don\'t know"
                        ;;
esac





