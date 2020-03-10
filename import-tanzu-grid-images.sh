#!/bin/bash -e

K8S_VERSION=$1
REGISTRY=$2
ETCD_VERSION=$3
COREDNS_VERSION=$4

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
    wget ${BASE_URL}${image}.tar.gz
done
gunzip *.tar.gz

ctr images import coredns*.tar
ctr images import etcd*.tar

ctr images ls

ctr images tag ${REGISTRY}/coredns:${COREDNS_VERSION}_vmware.3 ${REGISTRY}/coredns:${COREDNS_FIXED_VERSION}
ctr images tag ${REGISTRY}/etcd:${ETCD_VERSION}_vmware.3 ${REGISTRY}/etcd:${ETCD_FIXED_VERSION}
ctr images tag ${REGISTRY}/coredns:${COREDNS_VERSION}_vmware.3 ${REGISTRY}/coredns:${COREDNS_FIXED_VERSION}-0
ctr images tag ${REGISTRY}/etcd:${ETCD_VERSION}_vmware.3 ${REGISTRY}/etcd:${ETCD_FIXED_VERSION}-0

ctr images export coredns.tar ${REGISTRY}/coredns:${COREDNS_FIXED_VERSION}
ctr images export etcd.tar ${REGISTRY}/etcd:${ETCD_FIXED_VERSION}-0

CONTAINERD_NAMESPACE="k8s.io" ctr images import kube-apiserver*.tar
CONTAINERD_NAMESPACE="k8s.io" ctr images import kube-controller*.tar
CONTAINERD_NAMESPACE="k8s.io" ctr images import kube-proxy*.tar
CONTAINERD_NAMESPACE="k8s.io" ctr images import kube-scheduler*.tar
CONTAINERD_NAMESPACE="k8s.io" ctr images import pause*.tar
CONTAINERD_NAMESPACE="k8s.io" ctr images import coredns.tar
CONTAINERD_NAMESPACE="k8s.io" ctr images import etcd.tar

ctr images ls
crictl images

rm *.tar
ls -ll

