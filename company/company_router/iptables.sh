#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to display usage and exit
usage_and_exit() {
    if [ "$1" = "none" ]; then
        echo "Usage: $0 none"
    else
        echo "Usage: $0 [memory|speed] <limit_value> <ip_address>"
    fi
    exit 1
}

# Define network interfaces
company="enp0s9"
isp="enp0s3"

# Enable IP forwarding
echo "1" > /proc/sys/net/ipv4/ip_forward

# Flush existing iptables rules
iptables -F
iptables -X M_LIMIT_IP
iptables -X S_LIMIT_IP

# Apply the chosen configuration based on the first argument
case $1 in
    memory|speed)
        if [ "$#" -ne 3 ]; then
            usage_and_exit
        fi
        LIMIT_VALUE=$2
        IP_ADDRESS=$3
        ;;
    none)
        if [ "$#" -ne 1 ]; then
            usage_and_exit "none"
        fi
        ;;
    *)
        usage_and_exit
        ;;
esac

# Function to set memory limits
setup_memory_limits() {
    iptables -N M_LIMIT_IP
    iptables -A FORWARD -i $company -o $isp -j M_LIMIT_IP
    iptables -A FORWARD -i $isp -o $company -j M_LIMIT_IP
    iptables -A M_LIMIT_IP -i $company -o $isp -s $IP_ADDRESS -m quota --quota $LIMIT_VALUE -j ACCEPT
    iptables -A M_LIMIT_IP -s $IP_ADDRESS -j DROP
}

# Function to set speed limits
setup_speed_limits() {
    iptables -N S_LIMIT_IP
    iptables -A FORWARD -i $company -o $isp -j S_LIMIT_IP
    iptables -A FORWARD -i $isp -o $company -j S_LIMIT_IP
    iptables -A S_LIMIT_IP -i $company -o $isp -s $IP_ADDRESS -m limit --limit $LIMIT_VALUE/s -j ACCEPT
    iptables -A S_LIMIT_IP -s $IP_ADDRESS -j DROP
}

# Conditionally call setup functions based on the chosen configuration
if [ "$1" = "memory" ]; then
    setup_memory_limits
elif [ "$1" = "speed" ]; then
    setup_speed_limits
fi

# Display current iptables configuration
iptables --line-numbers -L -n -v

