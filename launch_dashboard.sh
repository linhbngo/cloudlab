#!/bin/bash

kubectl apply -f k8s_dashboard/dashboard-insecure.yaml
kubectl apply -f k8s_dashboard/socat.yaml
kubectl get svc --namespace=kubernetes-dashboard
kubectl patch service kubernetes-dashboard -n kubernetes-dashboard --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30082}]'
