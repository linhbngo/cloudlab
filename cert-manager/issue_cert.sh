#!/bin/bash
set -x

cp /local/repository/cert-manager/x509.yaml .
sed -i "s/MYDOMAIN/$1/g" x509.yaml
kubectl apply -f x509.yaml

kubectl describe certificate $1-cert

kubectl get secret
kubectl get secret $1-cert-secret
