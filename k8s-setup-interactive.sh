#!/bin/bash

# Ask if this is master or worker
read -p "Is this node a master? (yes/no): " NODE_TYPE

# Shared setup for both master and worker
echo "📛 Setting hostname"
if [[ "$NODE_TYPE" == "yes" ]]; then
  sudo hostnamectl set-hostname master
else
  sudo hostnamectl set-hostname worker
fi

echo "📦 Installing Docker"
sudo apt update && sudo apt install -y docker.io
sudo systemctl enable docker && sudo systemctl start docker

echo "❌ Disabling swap"
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "🌐 Installing Kubernetes dependencies"
sudo apt install -y apt-transport-https curl gpg

# ✅ Secure way to add Kubernetes repo for Ubuntu 22.04+/24.04
echo "🔑 Adding Kubernetes GPG key using keyrings method"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "📦 Adding Kubernetes APT repository"
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] \
https://apt.kubernetes.io/ kubernetes-xenial main" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

echo "📦 Updating APT again"
sudo apt update

echo "⬇️ Installing Kubernetes tools (version 1.28.0)"
sudo apt install -y kubelet=1.28.0-00 kubeadm=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubeadm kubectl

# MASTER NODE SETUP
if [[ "$NODE_TYPE" == "yes" ]]; then
  echo "🚀 Initializing Kubernetes master"
  sudo kubeadm init --pod-network-cidr=192.168.0.0/16

  echo "🔧 Configuring kubectl for the ubuntu user"
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  echo "🌐 Installing Calico CNI plugin"
  kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

  echo "✅ Master node setup complete!"
  echo "📋 Copy the 'kubeadm join' command shown above and run it on the worker nodes"

# WORKER NODE SETUP
else
  echo "✅ Worker node setup complete!"
  echo "🚀 Now run the kubeadm join command (from master) to add this node to the cluster"
fi
