#!/bin/bash

#The Script will install Kubectl on the Management Server and download the .kube/config from Kubernetes Master

sudo apt-get update
sudo apt-get upgrade -y
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt-get update
sudo apt-get install -y kubectl=$k8sversion
sudo apt-mark hold kubectl
mkdir -p $HOME/.kube
scp $k8smaster:.kube/config $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
