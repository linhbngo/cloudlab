#!/bin/bash 
set -x

sudo apt-get update
sudo apt-get install -y nfs-kernel-server
sudo mkdir -p /opt/keys/flagdir
sudo chown nobody:nogroup /opt/keys
sudo chmod -R a+rwx /opt/keys

# setup home and software directory
for list_dir in home software scratch
do
  sudo mkdir -p /opt/${list_dir}
  sudo chown nobody:nogroup /opt/${list_dir}
  sudo chmod -R a+rwx /opt/${list_dir}
done

for i in $(seq 2 $2)
do
  for nfs_dir in home software scratch keys
  do 
    echo "/opt/${nfs_dir} 192.168.1.$i(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
  done
done
sudo systemctl restart nfs-kernel-server

# setup RKE2
curl -sfL https://get.rke2.io | sh - 
systemctl enable rke2-server.service
systemctl start rke2-server.service

cp /var/lib/rancher/rke2/server/node-token /opt/keys/

while IFS= read -r line; do
  mkdir -p /users/$line/.kube
  sudo cp -i /etc/rancher/rke2/rke2.yaml /users/$line/.kube/config
  sudo chown $line: /users/$line/.kube/config
done < <( cat /etc/passwd | grep bash | cut -d':' -f1 )
