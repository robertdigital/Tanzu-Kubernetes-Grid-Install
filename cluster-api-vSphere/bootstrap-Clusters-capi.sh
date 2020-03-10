#!/bin/bash



# Generate the cluster components yaml files
docker run --rm -v "$(pwd)":/out \
  -v "$(pwd)/envvars.txt":/envvars.txt:ro \
  gcr.io/cluster-api-provider-vsphere/release/manifests:latest -c tkg-workload


#Create the capi and capv components, by applying the yaml file generated in previous step 
kubectl apply -f out/tkg-workload-1/
