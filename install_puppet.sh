#!/bin/bash

# setup Java
dnf install -y java-11-openjdk.x86_64

# get Puppet source
dnf config-manager --set-enable powertools
rpm -Uvh http://yum.puppet.com/puppet-release-el-7.noarch.rpm
dnf update -y

# install puppet server
if [ $1 = "server" ]; then
  dnf install -y puppetserver
  sed -i 's/-Xms2g -Xmx2g/-Xms512m -Xmx512m/g' /etc/sysconfig/puppetserver
  cp /local/repository/puppet/puppet.conf /etc/puppetlabs/puppet/puppet.conf
  /opt/puppetlabs/bin/puppetserver ca setup
  systemctl enable --now puppetserver
  systemctl restart puppetserver
else
  dnf -y install puppet-agent
  sed -i "s/AGENT/$1/g" /local/repository/puppet/puppet-agent.conf
  cp /local/repository/puppet/puppet-agent.conf /etc/puppetlabs/puppet/puppet.conf
fi

