#!/bin/bash

# Script for setting up DHCP server configuration

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Define DHCP server interface
dhcp_interface="enp0s8"

# Install DHCP server if not installed
if ! dpkg -l | grep -qw isc-dhcp-server; then
    apt-get update
    apt-get install -y isc-dhcp-server
fi

# Configure DHCP server to use the specified interface
echo "INTERFACESv4=\"$dhcp_interface\"" > /etc/default/isc-dhcp-server

# DHCP server configuration
dhcp_config="/etc/dhcp/dhcpd.conf"

# Write DHCP configuration
cat > "$dhcp_config" <<EOF
subnet 10.207.128.0 netmask 255.255.192.0 {
  range 10.207.128.2 10.207.191.254;
  option routers 10.207.128.1;
}
EOF

# Restart DHCP service to apply new configuration
systemctl restart isc-dhcp-server

echo "DHCP server configuration complete."

