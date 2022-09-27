#!/bin/bash

set -x

helm repo add jenkins https://charts.jenkins.io
helm repo update

export KUBEHEAD=$(kubectl get nodes -o custom-columns=NAME:.status.addresses[1].address,IP:.status.addresses[0].address | grep head | awk -F ' ' '{print $2}')
cp /local/repository/jenkins/values.yaml .
sed -i "s/KUBEHEAD/$(cat /opt/keys/headnode)/g" values.yaml
helm install -f values.yaml jenkins/jenkins --generate-name

kubectl create sa jenkins
kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts
kubectl create clusterrolebinding jenkins --clusterrole cluster-admin --serviceaccount=default:jenkins
