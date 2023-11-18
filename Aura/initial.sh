#!/bin/bash

apt-get update
apt-get install isc-dhcp-relay -y
service isc-dhcp-relay start

echo '
net.ipv4.ip_forward=1
' >> /etc/sysctl.conf

echo '
SERVERS="10.72.1.2"
INTERFACES="eth1 eth2 eth3 eth4"
OPTIONS=""
' > /etc/default/isc-dhcp-relay

service isc-dhcp-relay restart