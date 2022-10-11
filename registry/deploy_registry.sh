#!/bin/bash
set -x
# adapted and automated basaed on the instructions from https://blog.zachinachshon.com/docker-registry/

bash /local/repository/registry/gen_htpasswd.sh
helm repo add twuni https://helm.twun.io

helm upgrade --install docker-registry \
    --set replicaCount=1 \
    --set secrets.htpasswd=$(cat $HOME/temp/registry-creds/htpasswd) \
    twuni/docker-registry \
    --version 1.10.1
   
#cp /local/repository/registry/ingress.yaml .
#sed -i "s/MYDOMAIN/$(hostname -d)/g" ingress.yaml

#kubectl apply -f ingress.yaml

#echo "Alternatively, add a new hosted name entry with a one-liner"
# echo -e "111.222.333.444\tregistry.MY_DOMAIN.com" | sudo tee -a /etc/hosts
