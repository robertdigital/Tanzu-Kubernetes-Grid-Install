#!/bin/bash

set -e
rm -f /tmp/Image_list.sh
K8S_VERSION=v1.17.2 #Update for your k8s version
ETCD_VERSION=v3.4.3
COREDNS_VERSION=v1.6.5
COREDNS_FIXED_VERSION=$(sed 's/v//g' <<< $COREDNS_VERSION) #Fixes CoreDNS name for standard manifest
ETCD_FIXED_VERSION=$(sed 's/v//g' <<< $ETCD_VERSION) #Fixes etcd name for standard manifest
echo "#!/bin/bash" > /tmp/Image_list.sh
chmod +x /tmp/Image_list.sh

LOCAL_REGISTRY= #Enter value of your local registry
BASE_URL=https://downloads.heptio.com/vmware-tanzu-kubernetes-grid/523a448aa3e9a0ef93ff892dceefee0a/images/
declare -a image_list=("kubernetes/${K8S_VERSION}%2Bvmware.1/kube-proxy-${K8S_VERSION}_vmware.1"
                       "kubernetes/${K8S_VERSION}%2Bvmware.1/kube-apiserver-${K8S_VERSION}_vmware.1"
                       "kubernetes/${K8S_VERSION}%2Bvmware.1/kube-controller-manager-${K8S_VERSION}_vmware.1"
                       "kubernetes/${K8S_VERSION}%2Bvmware.1/kube-scheduler-${K8S_VERSION}_vmware.1"
                       "kubernetes/${K8S_VERSION}%2Bvmware.1/pause-3.1"
                       "etcd/${ETCD_VERSION}%2Bvmware.3/etcd-${ETCD_VERSION}_vmware.3"
                       "coredns/${COREDNS_VERSION}%2Bvmware.3/coredns-${COREDNS_VERSION}_vmware.3")
for image in "${image_list[@]}"; do
    echo "Downloading ${image}"

    # Load images
    RESULT=$(curl ${BASE_URL}${image}.tar.gz | gunzip -c | docker load)
    IMAGE=${RESULT#*: }
    TAG=${IMAGE#*:}
    IMAGE_WITHOUT_TAG=${IMAGE%:*}
    REPO=${IMAGE_WITHOUT_TAG##*/}

    # Tag images
    echo "docker tag $IMAGE ${LOCAL_REGISTRY}/${REPO}:${TAG}"
    docker tag $IMAGE ${LOCAL_REGISTRY}/${REPO}:${TAG}

    # Push images
    echo "docker push ${LOCAL_REGISTRY}/${REPO}:${TAG}"
    docker push ${LOCAL_REGISTRY}/${REPO}:${TAG}
	echo "docker pull ${LOCAL_REGISTRY}/${REPO}:${TAG}" >> /tmp/Image_list.sh
done

# Update Local registry image for CoreDNS and etcd
docker tag ${LOCAL_REGISTRY}/coredns:${COREDNS_VERSION}_vmware.3 ${LOCAL_REGISTRY}/coredns:${COREDNS_FIXED_VERSION}
docker tag ${LOCAL_REGISTRY}/etcd:${ETCD_VERSION}_vmware.3 ${LOCAL_REGISTRY}/etcd:${ETCD_FIXED_VERSION}
docker push ${LOCAL_REGISTRY}/coredns:${COREDNS_FIXED_VERSION}
docker push ${LOCAL_REGISTRY}/etcd:${ETCD_FIXED_VERSION}
echo "docker pull ${LOCAL_REGISTRY}/coredns:${COREDNS_FIXED_VERSION}" >> /tmp/Image_list.sh
echo "docker pull ${LOCAL_REGISTRY}/etcd:${ETCD_FIXED_VERSION}" >> /tmp/Image_list.sh

