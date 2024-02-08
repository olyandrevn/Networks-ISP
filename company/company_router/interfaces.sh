#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Network configuration to be added
CONFIG="auto enp0s3
iface enp0s3 inet static
address 10.207.0.3
netmask 255.255.128.0
gateway 10.207.0.1

auto enp0s9
iface enp0s9 inet static
address 10.207.192.1
netmask 255.255.192.0"

# Append configuration to /etc/network/interfaces
echo "$CONFIG" >> /etc/network/interfaces

# Restart networking service to apply changes
systemctl restart networking.service

echo "Network interface configuration updated and networking service restarted."
