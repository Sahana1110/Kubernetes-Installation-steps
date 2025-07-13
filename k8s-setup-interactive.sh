#!/bin/bash

# Ask user for node type
read -p "Is this node a master? (yes/no): " NODE_TYPE

if [[ "$NODE_TYPE" == "yes" ]]; then
  echo "📛 Setting hostname to 'master'"
  sudo hostnamectl set-hostname master

  echo "📦 Installing Docker"
  sudo apt update && sudo apt install -y docker.io
  sudo systemctl enable docker && sudo systemctl start docker

  echo "❌ Disabling swap"
  sudo swapoff -a
  sudo sed -i '/ swap / s/^/#/' /etc/fstab

  echo "🌐 Installing Kubernetes prerequisites"
  sudo apt install -y apt-transport-https curl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | \
    sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt update

  echo "⬇️ Installing Kubernetes (v1.28.0)"
  sudo apt install -y kubelet=1.28.0-00 kubeadm=1.28.0-00 kubectl=1.28.0-00
  sudo apt-mark hold kubelet kubeadm kubectl

  echo "🚀 Initializing Kubernetes master"
  sudo kubeadm init --pod-network-cidr=192.168.0.0/16

  echo "🔧 Setting up kubectl config"
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  echo "🌐 Installing Calico CNI plugin"
  kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

  echo "✅ Master node setup complete!"
  echo "📋 Save the 'kubeadm join' command shown above to join worker nodes."

else
  echo "📛 Setting hostname to 'worker' (you can rename later if needed)"
  sudo hostnamectl set-hostname worker

  echo "📦 Installing Docker"
  sudo apt update && sudo apt install -y docker.io
  sudo systemctl enable docker && sudo systemctl start docker

  echo "❌ Disabling swap"
  sudo swapoff -a
  sudo sed -i '/ swap / s/^/#/' /etc/fstab

  echo "🌐 Installing Kubernetes prerequisites"
  sudo apt install -y apt-transport-https curl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | \
    sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt update

  echo "⬇️ Installing Kubernetes (v1.28.0)"
  sudo apt install -y kubelet=1.28.0-00 kubeadm=1.28.0-00 kubectl=1.28.0-00
  sudo apt-mark hold kubelet kubeadm kubectl

  echo "✅ Worker node setup complete!"
  echo "🚀 Now run the 'kubeadm join' command from the master to add this node."
fi
