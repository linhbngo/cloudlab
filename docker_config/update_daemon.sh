#!/bin/bash

cp /local/repository/docker_config/daemon_template.json /opt/keys/daemon.json
ip_address=$(ip addr | grep eth0| awk -F ' ' '{print $2}' | awk -F '/' '{print $1'} | tail -n 1)
sed -i "s/REGISTRY/${ip_address}/g" /opt/keys/daemon.json

