#!/bin/bash

apt install -y apt-transport-https ca-certificates
wget -O /tmp/ondemand-release-web_3.0.0_all.deb https://apt.osc.edu/ondemand/3.0/ondemand-release-web_3.0.0_all.deb
apt install -y /tmp/ondemand-release-web_3.0.0_all.deb 
apt update -y
apt install -y ondemand

systemctl start apache2
systemctl enable apache2
