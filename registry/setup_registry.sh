#!/bin/bash

1  clear
    2  mkdir registry
    3  cd registry/
    4  mkdir certs
    5  mkdir auth
    6  cd certs/
    7  openss genrsa 1024 > domain.key
    8  openssl genrsa 1024 > domain.key
    9  chmod 400 domain.key
   10  nano san.cnf
   11  ip addr | grep 130
   12  ip addr
   13  ping clnodevm200-1.clemson.cloudlab.us
   14  nano san.cnf
   15  openssl req -new -x509 -nodes -sha1 -days 365 -key domain.key -out domain.crt -config san.cnf
   16  cd ../auth
   17  docker run --rm --entrypoint htpasswd registry:2.7.0 -Bbn admin registry > htpasswd
   18  cd ..


# on Kubernetes pod
sudo mkdir -p /etc/docker/certs.d/130.127.132.216:443
    2  sudo nano /etc/docker/certs.d/130.127.132.216\:443/
    3  sudo nano /etc/docker/certs.d/130.127.132.216\:443/ca.crt
    4  docker login -u admin -p https://130.127.132.216:443
    5  docker login -u admin -p registry https://130.127.132.216:443
