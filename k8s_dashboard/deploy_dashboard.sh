#!/bin/bash

set -x

kubectl apply -f /local/repository/k8s_dashboard/dashboard-insecure.yaml
kubectl apply -f /local/repository/k8s_dashboard/socat.yaml
