#!/bin/bash

# setup Java
dnf install -y java-11-openjdk.x86_64

# get Puppet source
dnf config-manager --set-enable powertools
rpm -Uvh http://yum.puppet.com/puppet-release-el-9.noarch.rpm
dnf update -y

# install puppet server
if [ $1 = "server" ]; then
  dnf install -y puppetserver
  sudo sed -i 's/-Xms2g -Xmx2g/-Xms512m -Xmx512m/g' /etc/sysconfig/puppetserver
else

fi

