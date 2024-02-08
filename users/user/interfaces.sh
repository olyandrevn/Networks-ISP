#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Define the configuration for enp0s8
CONFIG="auto enp0s8
iface enp0s8 inet dhcp
gateway 10.128.0.1"

# Append configuration to /etc/network/interfaces
echo "$CONFIG" >> /etc/network/interfaces

# Restart networking service to apply changes
systemctl restart networking

echo "Network interface enp0s8 configured for DHCP and networking service restarted."

