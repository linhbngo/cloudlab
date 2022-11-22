#!/bin/bash

# create the certs in the shared /keys directory
mkdir -p /opt/keys/certs
cd /opt/keys/certs
openssl genrsa 1024 > domain.key
chmod 400 domain.key
cp /local/repository/registry/san.cnf.template san.cnf
ip_address=$(ip addr | grep eth0$ | awk -F ' ' '{printf $2}' | awk -F '/' '{printf $1'})
sed -i "s/IPADDR/${ip_address}/g" sans.cnf
openssl req -new -x509 -nodes -sha1 -days 365 -key domain.key -out domain.crt -config san.cnf

# create login/password in the shared /keys directory
mkdir -p /opt/keys/auth
cd /opt/keys/auth
docker run --rm --entrypoint htpasswd registry:2.7.0 -Bbn admin registry > htpasswd

# create a template subdirectory to be mounted to pods
mkdir -p /opt/keys/certs.d/${ip_address}:443
cp /opt/keys/certs/domain.crt /opt/keys/certs.d/${ip_address}:443/ca.crt

# on Kubernetes pod
#sudo mkdir -p /etc/docker/certs.d/130.127.132.216:443
#    2  sudo nano /etc/docker/certs.d/130.127.132.216\:443/
#    3  sudo nano /etc/docker/certs.d/130.127.132.216\:443/ca.crt
#    4  docker login -u admin -p https://130.127.132.216:443
#    5  docker login -u admin -p registry https://130.127.132.216:443
