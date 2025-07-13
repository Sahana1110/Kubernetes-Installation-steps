#!/bin/bash

# 📛 Set hostname
echo "📛 Setting hostname to 'worker1' (change manually for worker2)"
sudo hostnamectl set-hostname worker1

# 📦 Install Docker
echo "📦 Installing Docker"
sudo apt update && sudo apt install -y docker.io
sudo systemctl enable docker && sudo systemctl start docker

# ❌ Disable swap
echo "❌ Disabling swap"
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 🌐 Install dependencies
echo "🌐 Installing apt-transport-https and curl"
sudo apt install -y apt-transport-https curl

echo "🔑 Adding Kubernetes GPG key"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "📦 Adding Kubernetes apt repo"
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "📦 Updating apt"
sudo apt update

# 📦 Install specific Kubernetes version (1.28.0)
echo "⬇️ Installing kubelet, kubeadm, kubectl (v1.28.0)"
sudo apt install -y kubelet=1.28.0-00 kubeadm=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubeadm kubectl

# ℹ️ Wait for join command
echo "✅ Worker setup complete. Now paste the 'kubeadm join ...' command from the master."
