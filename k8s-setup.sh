#!/bin/bash

#Swap must be disabled for Kubernetes
sudo swapoff -a
sudo sed -i -e 's\/swap.img\#/swap.img\g' /etc/fstab

#Bring the System up to date
sudo apt-get update
sudo apt-get upgrade -y

#Install Docker and change the croupdriver to systemd
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
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
sudo mkdir /etc/apt/keyrings
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt-get install -y kubeadm=1.28.1-1.1 kubelet=1.28.1-1.1 kubectl=1.28.1-1.1
sudo apt-mark hold kubelet kubeadm kubectl

#For the NFS Provisioner we need to install the NfS Client on all Kubernetes Mashines
sudo apt install nfs-client -y

#To use the full Disksize for Kubernete we need to increase the logical Volume
sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
