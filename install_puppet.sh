#!/bin/bash

# setup Java
dnf install -y java-11-openjdk.x86_64

# get Puppet source
dnf config-manager --set-enable powertools
 
rpm -Uvh http://yum.puppet.com/puppet-release-el-9.noarch.rpm
dnf update -y
yum install -y puppetserver


