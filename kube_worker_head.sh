#!/bin/bash

command=`tail -n 2 /opt/keys/kube.log | tr -d '\\'`
echo $command
sudo $command
