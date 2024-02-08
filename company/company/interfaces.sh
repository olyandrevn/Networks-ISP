#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Define the configuration for enp0s9
CONFIG="auto enp0s9
iface enp0s9 inet static
address 10.207.192.2
netmask 255.255.192.0
gateway 10.207.192.1"

# Append configuration to /etc/network/interfaces
echo "$CONFIG" >> /etc/network/interfaces

# Restart networking service to apply changes
systemctl restart networking

echo "Network interface configuration updated and networking service restarted."

