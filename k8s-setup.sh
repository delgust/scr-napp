#!/bin/bash

#Swap must be disabled for Kubernetes
sudo swapoff -a
sudo sed -i -e 's\/swap.img\#/swap.img\g' /etc/fstab

#Bring the System up to date
sudo apt-get update
sudo apt-get upgrade -y

#Install Docker and change the croupdriver to systemd
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo mkdir -p /etc/apt/keyrings
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt upgrade
sudo apt-get install -y docker.io
sudo systemctl enable docker.service
sudo systemctl start docker
sudo touch /etc/docker/daemon.json
sudo printf \
'{
   "exec-opts": ["native.cgroupdriver=systemd"],
   "log-driver": "json-file",
   "log-opts": { "max-size": "100m" },
   "storage-driver": "overlay2"
}'\
| sudo tee -a /etc/docker/daemon.json
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker

#Install Kubernetes Packages
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.24/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.24/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt-get install -y kubeadm=1.24.17 kubelet=1.24.17 kubectl=1.24.17
sudo apt-mark hold kubelet kubeadm kubectl

#For the NFS Provisioner we need to install the NfS Client on all Kubernetes Mashines
sudo apt install nfs-client -y

#To use the full Disksize for Kubernete we need to increase the logical Volume
sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
