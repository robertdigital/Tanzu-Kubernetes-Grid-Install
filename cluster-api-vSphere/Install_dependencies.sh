#!/bin/bash


#Install TKG signed binaries
curl -O https://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub
gpg --import VMWARE-PACKAGING-GPG-RSA-KEY.pub && gpg --verify vmware-kubernetes*.tar.gz.sha256{.asc,}

#Install Kubeadm on Ubuntu
#!/bin/bash

set -e

K8S_VERSION=1.17.3+vmware.1-1 #update to your version of k8s

APT_REPOSITORY_KEY="https://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub"
APT_REPOSITORY="deb https://downloads.heptio.com/vmware-tanzu-kubernetes-grid/523a448aa3e9a0ef93ff892dceefee0a/debs stable main"

sudo apt-get install -y software-properties-common
wget -qO - "${APT_REPOSITORY_KEY}" | sudo apt-key add -
sudo apt-add-repository "${APT_REPOSITORY}"
sudo apt-get update
sudo apt-get install -y kubelet="${K8S_VERSION}" kubeadm="${K8S_VERSION}" kubectl="${K8S_VERSION}" cri-tools
apt-mark hold kubelet kubeadm kubectl cri-tools kubernetes-cni


#Obtain Container Images

#Install Docker 
apt-get install -y docker.io
systemctl daemon-reload
systemctl enable docker

chmod +x Obtain_images.sh
./Obtain_images.sh

#Run a local registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2

#Push to a private docker registry
chmod +x Image_list.sh
./Image_list.sh

#Copy Image_list.sh script to the other nodes of the cluster
NODE_IPS="<list_of_IP_addresses_for_all_master_workers>" #replace with values for your environment for host in ${NODE_IPS}; do
scp /tmp/Image_list.sh "${USER}"@$host:
done



