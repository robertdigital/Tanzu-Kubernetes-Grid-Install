#!/bin/bash


#Install VMware Workstation on Linux or VMware Fusion on macOS - The machine images are created on your local workstation first.
#Install ovftool - This should be installed automatically when workstation or fusion is installed.
#On macos, install ovftool and configure vmware-vdiskmanager as follows:

ln -sf "/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager" /usr/local/bin/vmware-vdiskmanager

echo "/Applications/VMware Fusion.app/Contents/Library/" >> /etc/paths

#Install govc - CLI used to upload resulting machine image into target vSphere cluster


brew install packer
brew install ansible

#clone image-builder project and checkout a specific commit
git clone https://github.com/kubernetes-sigs/image-builder.git
cd image-builder
git checkout 688b2975
cd ../

#Update the configuration file tanzu-grid.json with your desired version of Tanzu Kubernetes Grid. The example uses 1.16.2.

#Make the import-tanzu-grid-images.sh script executable, to import the required Tanzu Kubernetes Grid container images

chmod +x import-tanzu-grid-images.sh

#use the packer-vsphere.json to create the vSphere builder configuration


#Build the vSphere OVA with packer, using tanzu-grid.json
packer build \
    -var-file=../data/tanzu-grid.json \
    -var-file=image-builder/images/capi/packer/ova/ova-ubuntu-1804.json \
    ../data/packer-vsphere.json
