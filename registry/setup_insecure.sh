#!/bin/bash

kubectl create deployment registry --image=registry
kubectl expose deploy/registry --port=5000 --type=NodePort
kubectl patch service registry --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30500}]'
