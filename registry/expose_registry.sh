#!/bin/bash

export K8SECRET=$(kubectl get secret | grep tls | awk 'NR==1{print $1}')
kubectl get secret clnodevm190-1.clemson.cloudlab.us-cert-secret -o json | jq -r '.data."tls.crt"' | base64 -d > server.crt

export TLSPORT=$(kubectl get svc -n ingress-nginx -o wide | grep NodePort | awk 'NR==1{print $5}' | awk -F':' '{print $3}' | awk -F'/' '{print $1}')

sudo mkdir -p /etc/docker/certs.d/$(hostname -f)\:$TLSPORT/
sudo cp server.crt /etc/docker/certs.d/$(hostname -f)\:$TLSPORT/ca.crt

kubectl create ingress docker-registry --class=nginx --rule="$(hostname -f)/v2/=docker-registry:5000,tls=$(hostname -f)-cert-secret"
kubectl annotate ingress docker-registry nginx.ingress.kubernetes.io/rewrite-target="/"

export USER=$(cat $HOME/temp/registry-creds/registry-user.txt)
export PASSWORD=$(cat $HOME/temp/registry-creds/registry-pass.txt)
echo $USER
echo $PASSWORD

echo "Run docker login https://$(hostname -f):$TLSPORT/docker/ "
