#!/bin/bash

echo "DNS=10.96.0.10" | sudo tee /etc/systemd/resolved.conf
sudo systemctl daemon-reload
sudo systemctl restart systemd-networkd
sudo systemctl restart systemd-resolved
