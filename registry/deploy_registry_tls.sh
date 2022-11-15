#!/bin/bash
set -x
# adapted and automated basaed on the instructions from https://blog.zachinachshon.com/docker-registry/

bash /local/repository/registry/gen_htpasswd.sh
helm repo add twuni https://helm.twun.io

helm upgrade --install docker-registry \
    --set replicaCount=1 \
    --set secrets.htpasswd=$(cat $HOME/temp/registry-creds/htpasswd) \
    --set tlsSecretName=docker-registry-cert-secret \
    twuni/docker-registry \
    --version 1.10.1
