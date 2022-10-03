#!/bin/bash

kubectl create namespace traefik
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm upgrade --install traefik \
    --namespace traefik \
    --set dashboard.enabled=true \
    --set rbac.enabled=true \
    --set="additionalArguments={--api.dashboard=true,--log.level=INFO,--providers.kubernetesingress.ingressclass=traefik-internal,--serversTransport.insecureSkipVerify=true}" \
    traefik/traefik \
    --version 9.1.1
    
    
