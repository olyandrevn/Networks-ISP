<h1 align="center">Networks-ISP</h1>
<p>
</p>


## Overview

1. ISP network has IPv4 segments: 
- Private with ip subnet ```10.207.0.0/17```
- Users with ip subnet ```10.207.128.0/18```
- Company with ip subnet ```10.207.192.0/18```
2. “Users” segment  have NAT.
3. ISP has 3 plans - with limited speed, with limited traffic, with unlimited speed and traffic


The system will look like this:
- local machine is used as Router#1 BGP with external address ```10.10.10.207``` and local address ```10.207.0.0.1```
- 2 virtual machines are used as Router#2 Users with local address ```10.207.0.0.2``` and Router#3 Company with local address ```10.207.0.0.3```
- 2 virtual machines are used as User Client with DHCP local addres and Company Client with local addres 10.207.192.2

![Screenshot from 2024-01-27 12-34-42](https://github.com/olyandrevn/Networks-ISP/assets/33371372/caeeb15e-b1a1-4216-afd6-b122582766e5)


## Install

### 1. Install VirtualBox:
[Download](https://www.virtualbox.org/wiki/Downloads) VirtualBox platform package for your system and install it using following commands:

```
sudo dpkg -i virtualbox-version-number_Ubuntu_xenial_amd64.deb
sudo rcvboxdrv setup
```

For more information check the [link](https://www.virtualbox.org/manual/ch02.html#externalkernelmodules).

### 2. Setup VirtualBox:
[Download](https://www.debian.org/distrib/netinst) Debian ISO and create 4 virtual machines. Next will need to set up network connection.

#### 2.1. Setup Host-Only Adapter:
Since Router#2 Users and Router#3 Company should be connected to Router#1 BGP, which is our local machine, we'll new to create Host-Only Adapter:

![Screenshot from 2024-02-08 17-50-46](https://github.com/olyandrevn/Networks-ISP/assets/33371372/45ebb310-604f-45b5-aabe-de2341f76b0d)

#### 2.1. Setup Network Adapters:
Each Adapter is the analogy of cable connection.
- Adapter 1 ```enp0s3``` will be used for Routers connection, it should be attached to **Host-Only Adapter**;
- Adapter 2 ```enp0s8``` will be used for Users subnet, it should be attached to **Internal Network**;
- Adapter 3 ```enp0s9``` will be used for Company subnet, it should be attached to **Internal Network**;

### 3. Setup Users subnet with NAT:
#### 3.1. Setup Router#2 Users:
1. To setup interfaces:
```
sudo bash users/users_router/interfaces.sh
```
After this virtual machine should be restarted.

2. To setup ip_forward and NAT:
```
sudo bash users/users_router/iptables.sh none
```
3. To setup DHCP:
```
sudo bash users/users_router/dhcp.sh
```

#### 3.1. Setup User Client with DHCP:
To setup interfaces:
```
sudo bash users/user/interfaces.sh
```
After this virtual machine should be restarted.

### 4. Setup Company subnet:
#### 4.1. Setup Router#3 Company:
1. To setup interfaces:
```
sudo bash company/company_router/interfaces.sh
```
After this virtual machine should be restarted.

2. To setup ip_forward:
```
sudo bash company/company_router/iptables.sh none
```
#### 4.2. Setup Company Client:
To setup interfaces:
```
sudo bash company/company/interfaces.sh
```
After this virtual machine should be restarted.

### 4. Setup Router#1 BGP:
1. Install bird
```
sudo apt install bird2
```
2. Update ```bird.conf```:
```
sudo cp bgp/bird.conf /etc/bird/bird.conf
```
3. Setup ip_forward:
```
sudo sysctl -w net.ipv4.ip_forward=1
```

### 5. Traffic and speed limits:
To set up traffic or speed limit:
```
sudo bash company/company_router/iptables.sh [memory|speed] <limit_value> <ip_address>
OR
sudo bash users/users_router/iptables.sh [memory|speed] <limit_value> <ip_address>
```
## Usage
1. Install wireguard VPN
2. Unpack the zip archive
3. [Import](https://developerinsider.co/how-to-set-up-wireguard-client-on-ubuntu/) wireguard VPN configuration (named 207.conf)
4. Run wireguard VPN.
5. Run ```tester.py``` from Users/Company Client networks and see the output
