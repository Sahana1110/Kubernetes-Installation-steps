#!/bin/bash

# 📛 Set hostname
echo "📛 Setting hostname to 'master'"
sudo hostnamectl set-hostname master

# 📦 Update and install Docker
echo "📦 Installing Docker"
sudo apt update && sudo apt install -y docker.io
sudo systemctl enable docker && sudo systemctl start docker

# ❌ Disable swap
echo "❌ Disabling swap"
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 🌐 Install Kubernetes dependencies
echo "🌐 Installing dependencies"
sudo apt install -y apt-transport-https curl

echo "🔑 Adding Kubernetes GPG key"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "📦 Adding Kubernetes apt repo"
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "📦 Updating apt again"
sudo apt update

# 📦 Install specific Kubernetes version (1.28.0)
echo "⬇️ Installing kubelet, kubeadm, kubectl (v1.28.0)"
sudo apt install -y kubelet=1.28.0-00 kubeadm=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubeadm kubectl

# 🚀 Initialize Kubernetes cluster
echo "🚀 Initializing Kubernetes master"
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# 🔧 Configure kubectl for user
echo "🔧 Setting up kubeconfig"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 🌐 Install Calico CNI plugin
echo "🌐 Installing Calico CNI"
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "✅ Master node setup complete!"
