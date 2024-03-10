#!/bin/bash

kubectl patch svc proxy-public -n jhub -p '{"spec": {"type": "LoadBalancer", "externalIPs":["HOSTNODE"]}}'
