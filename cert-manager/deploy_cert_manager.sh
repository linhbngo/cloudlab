#!/bin/bash
set -x

kubectl create namespace container-registry
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager --namespace cert-manager jetstack/cert-manager --set installCRDs=true


cp /local/repository/cert-manager/cluster-issuer.yaml .
kubectl apply -f cluster-issuer.yaml
kubectl get clusterissuers k8s-ca-issuer -o wide

#cp /local/repository/cert-manager/x509.yaml .
#sed -i "s/MYDOMAIN/$(hostname -f)/g" x509.yaml
#kubectl apply -f x509.yaml

#kubectl describe certificate $(hostname -f)-cert

#kubectl get secret
#kubectl get secret $(hostname -f)-cert-secret
