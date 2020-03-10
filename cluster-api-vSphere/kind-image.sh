#!/bin/bash

export SOURCE_IMAGE="kindest/node:v1.16.2"
export BUILD_CONTAINER="tanzu-build"
export BUILD_IMAGE="tanzu-node:v1.16.2"

docker run -e "CONTAINERD_NAMESPACE=k8s.io" -v `pwd`/release:/release --privileged -it -d --name ${BUILD_CONTAINER} ${SOURCE_IMAGE}

# kubernetes images
for i in release/*/images/*.tar.gz; do
CMD="gunzip -c /$i | ctr images import -"
docker exec -it ${BUILD_CONTAINER} bash -c "$CMD"
done

docker exec -it ${BUILD_CONTAINER} bash -c "ctr images tag vmware.io/etcd:v3.3.15_vmware.3 vmware.io/etcd:3.3.15-0"
docker exec -it ${BUILD_CONTAINER} bash -c "ctr images tag vmware.io/coredns:v1.6.2_vmware.3 vmware.io/coredns:1.6.2"

# clusterapi images
for i in release/cluster-api/*/images/*.tar.gz; do
CMD="gunzip -c /$i | ctr images import -"
docker exec -it ${BUILD_CONTAINER} bash -c "$CMD"
done

# kubernetes binaries
docker exec -it ${BUILD_CONTAINER} bash -c 'gunzip -c /release/kubernetes*/executables/kubeadm-linux*.1.gz > /usr/bin/kubeadm'
docker exec -it ${BUILD_CONTAINER} bash -c 'gunzip -c /release/kubernetes*/executables/kubelet-linux*.1.gz > /usr/bin/kubelet'
docker exec -it ${BUILD_CONTAINER} bash -c 'gunzip -c /release/kubernetes*/executables/kubectl-linux*.1.gz > /usr/bin/kubectl'

docker stop ${BUILD_CONTAINER}
docker commit ${BUILD_CONTAINER} ${BUILD_IMAGE}
docker rm ${BUILD_CONTAINER}

