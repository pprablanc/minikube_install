#!/bin/bash

echo "Step 1: update system"
yum update -y

echo "Step 2: Install KVM hypervisor"

yum -y install epel-release
yum -y install libvirt qemu-kvm virt-install virt-top libguestfs-tools bridge-utils
systemctl start libvirtd
systemctl enable libvirtd
systemctl status libvirtd
usermod -a -G libvirt $(whoami)
sed 's/^\#\(unix_sock_group =\)/\1/'   /etc/libvirt/libvirtd.conf
sed 's/^\#\(unix_sock_rw_perms =\)/\1/'  /etc/libvirt/libvirtd.conf
systemctl restart libvirtd.service

echo "Step 3: Install Minikube"

wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
mv minikube-linux-amd64 /usr/bin/minikube
minikube version
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl  /usr/bin/
kubectl version --client -o json
minikube start
