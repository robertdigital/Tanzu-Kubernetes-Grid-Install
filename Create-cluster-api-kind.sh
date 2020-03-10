#!/bin/bash

#Install Kind on macOs
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.6.1/kind-darwin-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

#Install Kind on Linux
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.6.1/kind-darwin-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


# Create a tkg cluster

#download tkg release
wget https://downloads.heptio.com/vmware-tanzu-kubernetes-grid/523a448aa3e9a0ef93ff892dceefee0a/vmware-kubernetes-v1.16.2%2Bvmware.2.tar.gz

tar -xf vmware-kubernetes-v1.16.2+vmware.2.tar.gz
mv vmware-kubernetes-v1.16.2+vmware.2 release

#Build signed binary node image for Kind

chmod +x kind-image.sh
./kind-image.sh

#Create tanzu-kind.yaml file to configure Kind cluster

 cat > tanzu-kind.yaml <<EOF
 kind: Cluster
 apiVersion: kind.sigs.k8s.io/v1alpha3

 kubeadmConfigPatches:
 - |
     apiVersion: kubeadm.k8s.io/v1beta2
     kind: ClusterConfiguration
     metadata:
         name: config
     imageRepository: vmware.io
     kubernetesVersion: v1.16.2+vmware.1
 nodes:
 - role: control-plane
 EOF


kind delete cluster --name kind-tanzu

# Launch the cluster
kind create cluster \
    --name tanzu \
    --image tanzu-node:v1.16.2 \
    --config tanzu-kind.yaml \
    --wait 60s


# cluster-info
kubectl cluster-info --context kind-tanzu

kubectl get nodes -o wide

