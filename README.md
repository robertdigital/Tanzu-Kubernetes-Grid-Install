# Tanzu-Kubernetes-Grid-Install
Installation Steps of VMware Tanzu Kubernetes Grid using cluster-api

Steps to install VMware Tanzu Kubernetes Grid using cluster-api:

Step 1: Install dependencies, by running the Install_dependencies.sh script

Step 2: Create the cluster api management cluster with tkg signed binaries. To do so, run the script: Create-cluster-api-kind.sh

Step 3: Create the cluster-api components and boostrap the components on the management cluster, bu running the: Install-cluster-api.sh script

Step 4: Build OVA machine image for vSphere cluster, bu running the Build-OVA-vSphere.sh script Then, create the OVA template image on Vpshere, using Nimbus, as explained on this link: https://gitlab.eng.vmware.com/branda/esx-lab-nimbus/tree/master

Step 5: Boostrap the cluster with cluster-api on vSphere, by running the script: bootstrap-Clusters-capi.sh
