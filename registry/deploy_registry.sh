#!/bin/bash

# adapted and automated basaed on the instructions from https://blog.zachinachshon.com/docker-registry/

kubectl create namespace containter-registry

bash /local/repository/cert-manager/deploy_cert_manager.sh
