#!/bin/bash

apt update -y
# setup Java
apt install -y default-jdk

# get Puppet source
wget https://apt.puppet.com/puppet8-release-focal.deb
dpkg -i puppet8-release-focal.deb
apt update -y

# install puppet server
if [ $1 = "server" ]; then
  apt install -y puppetserver
  sed -i 's/-Xms2g -Xmx2g/-Xms512m -Xmx512m/g' /etc/default/puppetserver
  cp /local/repository/puppet/puppet.conf /etc/puppetlabs/puppet/puppet.conf
  /opt/puppetlabs/bin/puppetserver ca setup
  systemctl enable --now puppetserver
  systemctl restart puppetserver
else
  apt install -y puppet-agent
  sed -i "s/AGENT/$1/g" /local/repository/puppet/puppet-agent.conf
  cp /local/repository/puppet/puppet-agent.conf /etc/puppetlabs/puppet/puppet.conf
fi
