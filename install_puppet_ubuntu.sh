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
  set -x
  apt install -y nfs-kernel-server
  for list_dir in home software scratch keys
  do
    mkdir -p /opt/${list_dir}
    chown nobody:nogroup /opt/${list_dir}
    chmod -R a+rwx /opt/${list_dir}
  done
  
  for i in $(seq 2 $2)
  do
    for nfs_dir in home software scratch keys
    do 
      echo "/opt/${nfs_dir} 192.168.1.$i(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
    done
  done
  systemctl restart nfs-kernel-server
  apt install -y puppetserver
  sed -i 's/-Xms2g -Xmx2g/-Xms512m -Xmx512m/g' /etc/default/puppetserver
  cp /local/repository/puppet/puppet.conf /etc/puppetlabs/puppet/puppet.conf
  /opt/puppetlabs/bin/puppetserver ca setup
  systemctl enable --now puppetserver
  systemctl restart puppetserver
  touch /opt/keys/puppet_done
else
  apt install -y nfs-common
  mkdir -p /opt/keys
  while [ ! -f /opt/keys/puppet_done ]; do
    mount 192.168.1.1:/opt/keys /opt/keys
    sleep 10
  done
  for mount_dir in home software scratch
  do
    mkdir -p /opt/${mount_dir}
    mount 192.168.1.1:/opt/${mount_dir} /opt/${mount_dir}
  done
  apt install -y puppet-agent
  sed -i "s/AGENT/$1/g" /local/repository/puppet/puppet-agent.conf
  cp /local/repository/puppet/puppet-agent.conf /etc/puppetlabs/puppet/puppet.conf
  /opt/puppetlabs/bin/puppet agent --test --ca_server=head
  systemctl restart puppet
fi
