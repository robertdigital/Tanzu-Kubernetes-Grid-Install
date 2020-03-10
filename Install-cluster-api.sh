#!/bin/bash

#Download the manifests for both components

#wget https://github.com/kubernetes-sigs/cluster-api/releases/download/v0.2.7/cluster-api-components.yaml

#wget https://github.com/kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm/releases/download/v0.1.5/bootstrap-components.yaml


kubectl apply -f cluster-api-components.yaml
kubectl apply -f bootstrap-components.yaml

# confirm pods are running and referencing vmware images
kubectl get pods -A
kubectl get pods -A -o yaml | grep vmware.io


# Add a vSphere provider to the management cluster

# Generate the envvars.txt

cat <<EOF >envvars.txt
# vCenter config/credentials
export VSPHERE_SERVER='10.92.185.41'                # (required) The vCenter server IP or FQDN
export VSPHERE_USERNAME='administrator@vsphere.local'  # (required) The username used to access the remote vSphere endpoint
export VSPHERE_PASSWORD='Admin!23'  # (required) The password used to access the remote vSphere endpoint

# vSphere deployment configs
export VSPHERE_DATACENTER='SDDC-Datacenter'         # (required) The vSphere datacenter to deploy the management cluster on
export VSPHERE_DATASTORE='DefaultDatastore'         # (required) The vSphere datastore to deploy the management cluster on
export VSPHERE_NETWORK='vm-network-1'               # (required) The VM network to deploy the management cluster on
export VSPHERE_RESOURCE_POOL='vSAN-Cluster/Resources'            # (required) The vSphere resource pool for your VMs
export VSPHERE_FOLDER='tkg'                          # (optional) The VM folder for your VMs, defaults to the root vSphere folder if not set.
export VSPHERE_TEMPLATE='ubuntu-1804-kube-v1.15.4'  # (required) The VM template to use for your management cluster.
export VSPHERE_DISK_GIB='50'                        # (optional) The VM Disk size in GB, defaults to 20 if not set
export VSPHERE_NUM_CPUS='2'                         # (optional) The # of CPUs for control plane nodes in your management cluster, defaults to 2 if not set
export VSPHERE_MEM_MIB='2048'                       # (optional) The memory (in MiB) for control plane nodes in your management cluster, defaults to 2048 if not set
export SSH_AUTHORIZED_KEY='ssh-rsa AAAAB3N...'      # (optional) The public ssh authorized key on all machines in this cluster

# Kubernetes configs
export KUBERNETES_VERSION='1.16.2'        # (optional) The Kubernetes version to use, defaults to 1.16.2
export SERVICE_CIDR='100.64.0.0/13'       # (optional) The service CIDR of the management cluster, defaults to "100.64.0.0/13"
export CLUSTER_CIDR='100.96.0.0/11'       # (optional) The cluster CIDR of the management cluster, defaults to "100.96.0.0/11"
export SERVICE_DOMAIN='cluster.local'     # (optional) The k8s service domain of the management cluster, defaults to "cluster.local"
EOF




