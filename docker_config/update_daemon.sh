#!/bin/bash

cp /opt/keys/daemon.json /etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker

