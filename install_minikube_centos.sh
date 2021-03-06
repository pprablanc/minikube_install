#!/bin/bash

echo "Step 1: update system"
sudo yum update -y

echo "Step 3: Install docker if not installed"

docker
if [ $? -ne 0 ] ; then
  echo "Docker is not installed. Installing docker."
  ./install_docker.sh
fi


echo "Step 2: Install KVM hypervisor"

sudo yum -y install epel-release
sudo yum -y install libvirt qemu-kvm virt-install virt-top libguestfs-tools bridge-utils
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo systemctl status libvirtd
sudo usermod -a -G libvirt $(whoami)
sudo sed 's/^\#\(unix_sock_group =\)/\1/'   /etc/libvirt/libvirtd.conf
sudo sed 's/^\#\(unix_sock_rw_perms =\)/\1/'  /etc/libvirt/libvirtd.conf
sudo systemctl restart libvirtd.service

echo "Step 3: Install Minikube"

yum install -y conntrack
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/bin/minikube
minikube version
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv kubectl  /usr/bin/
kubectl version --client -o json
minikube start --vm-driver=none
systemctl enable kubelet.service


echo "Additional commands"

echo "Configuring bridge network iptables"
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "Kubernetes /etc/kubernetes/admin.conf config file"
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
echo "export KUBECONFIG=$HOME/admin.conf" >> $HOME/.bashrc



