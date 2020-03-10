#!/bin/bash

set -e

K8S_VERSION=v1.17.3 #Update for your k8s version
ETCD_VERSION=v3.4.3
COREDNS_VERSION=v1.6.5
COREDNS_FIXED_VERSION=$(sed 's/v//g' <<< $COREDNS_VERSION) #Fixes CoreDNS name for standard manifest
ETCD_FIXED_VERSION=$(sed 's/v//g' <<< $ETCD_VERSION) #Fixes etcd name for standard manifest

declare -a image_list=("kubernetes/${K8S_VERSION}%2Bvmware.1/kube-proxy-${K8S_VERSION}_vmware.1"
                       "kubernetes/${K8S_VERSION}%2Bvmware.1/kube-apiserver-${K8S_VERSION}_vmware.1"
                       "kubernetes/${K8S_VERSION}%2Bvmware.1/kube-controller-manager-${K8S_VERSION}_vmware.1"
                       "kubernetes/${K8S_VERSION}%2Bvmware.1/kube-scheduler-${K8S_VERSION}_vmware.1"
                       "kubernetes/${K8S_VERSION}%2Bvmware.1/pause-3.1"
                       "etcd/${ETCD_VERSION}%2Bvmware.3/etcd-${ETCD_VERSION}_vmware.3"
                       "coredns/${COREDNS_VERSION}%2Bvmware.3/coredns-${COREDNS_VERSION}_vmware.3")

BASE_URL=https://downloads.heptio.com/vmware-tanzu-kubernetes-grid/523a448aa3e9a0ef93ff892dceefee0a/images/

for image in "${image_list[@]}"; do
    echo "Downloading ${image}";
    curl -s ${BASE_URL}${image}.tar.gz | gunzip -c | docker load;
done

#Update the CoreDNS image so the default kubeadm manifests pick them up
docker tag vmware.io/coredns:${COREDNS_VERSION}_vmware.3 vmware.io/coredns:${COREDNS_FIXED_VERSION}
docker tag vmware.io/etcd:${ETCD_VERSION}_vmware.3 vmware.io/etcd:${ETCD_FIXED_VERSION}

