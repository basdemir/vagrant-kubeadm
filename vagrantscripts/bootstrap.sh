#!/bin/bash
# check if a go version is set

clear
echo "#################"
echo $0 $1
echo "#################"

nodeIp=$1

ls /usr/local/share/ca-certificates/PCAcer.crt > /dev/null 2>&1
CERT_INSTALLED=$?

if [ $CERT_INSTALLED -eq 0 ]; then
    echo "Cert Already Installed"
else
    echo "Installing Cert"
    sudo cp /vagrant/vagrantscripts/PCAcer.crt /usr/local/share/ca-certificates
    sudo update-ca-certificates 
fi

docker ps > /dev/null 2>&1
DOCKER_INSTALLED=$?

if [ $DOCKER_INSTALLED -eq 0 ]; then
    echo "Docker Already Installed"
else
    echo ">>> Installing docker"
    apt-get update
    sudo apt-get install -y docker.io
    echo ">>> Adding vagrant user to docker group"
    sudo usermod -aG docker vagrant
    sudo systemctl start docker
    sudo systemctl enable docker
fi

kubeadm > /dev/null 2>&1
KUBEADM_INSTALLED=$?

if [ $KUBEADM_INSTALLED -eq 0 ]; then
    echo "Kubeadm Already Installed"
else
    echo ">>> Installing Kubeadm"
    apt-get update && apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

    bash -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF'
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl

    # echo "Europe/Istanbul" | sudo tee /etc/timezone
    ln -fs /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
    dpkg-reconfigure --frontend noninteractive tzdata

    swapoff -a
    sed -i '/ swap / s/^/#/' /etc/fstab    

    echo ">>> INSTALLING kubens kubectx installation"
    git clone https://github.com/ahmetb/kubectx /opt/kubectx
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens

    echo ">>> INSTALLING Helm !!!"
    wget https://storage.googleapis.com/kubernetes-helm/helm-v2.12.1-linux-amd64.tar.gz
    tar -zxf helm-v2.12.1-linux-amd64.tar.gz
    mv linux-amd64/helm /usr/local/bin/helm
    rm -rf linux-amd64 helm-v2.12.1-linux-amd64.tar.gz
    
    echo ">>> Time to do vagrant reload !!!"
    # sudo shutdown now -r
fi

