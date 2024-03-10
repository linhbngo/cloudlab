#!/bin/bash

set -x

helm repo add jupyterhub https://hub.jupyter.org/helm-chart/
helm repo update

# assumption of where we are when running the scripts
cp -R /local/repository/jhub/ .
cd jhub

# Helm chart version 3.2.1 for JupyterHub 4.0.2
helm upgrade --cleanup-on-fail --install jhub jupyterhub/jupyterhub --namespace jhub --create-namespace --version=3.2.1 --values config.yaml

export HOSTNAME=$(kubectl get nodes -o custom-columns=NAME:.status.addresses[1].address,IP:.status.addresses[0].address | grep head | awk -F ' ' '{print $2}')

# Creating local-storage PV on each worker nodes
while IFS= read -r line; do
  cp ../pv/pvc-template.yml pvc.yml
  sed -i "s/KUBEHEAD/${line}/g" values.yaml 
done < <( kubectl get nodes -o custom-columns=NAME:.status.addresses[1].address | grep worker )

#cp /local/repository/jenkins/values.yaml .
#sed -i "s/KUBEHEAD/${KUBEHEAD}/g" values.yaml
#helm install jenkins jenkins/jenkins -f values.yaml 
