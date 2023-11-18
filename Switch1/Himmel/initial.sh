#!/bin/bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# Update package list
apt-get update
apt-get install isc-dhcp-server --no-install-recommends -y

echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server
echo 'INTERFACESv6=""' >> /etc/default/isc-dhcp-server

echo '
default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;

subnet 10.72.1.0 netmask 255.255.255.0 {
    option routers 10.72.1.1;
}

subnet 10.72.2.0 netmask 255.255.255.0 {
    option routers 10.72.2.1;
}

subnet 10.72.3.0 netmask 255.255.255.0 {
    range 10.72.3.16 10.72.3.32;
    range 10.72.3.64 10.72.3.80;
    option routers 10.72.3.1;
    option broadcast-address 10.72.3.255;
    option domain-name-servers 10.72.1.3;
    default-lease-time 180;
    max-lease-time 5760;
}

subnet 10.72.4.0 netmask 255.255.255.0 {
    range 10.72.4.12 10.72.4.20;
    range 10.72.4.160 10.72.4.168;
    option routers 10.72.4.1;
    option broadcast-address 10.72.4.255;
    option domain-name-servers 10.72.1.3;
    default-lease-time 720;
    max-lease-time 5760;
}

host Richter {
    hardware ethernet 32:7c:74:37:3a:f9;
    fixed-address 10.72.3.69;
}

host Revolte {
    hardware ethernet 26:90:6a:de:d0:0d;
    fixed-address 10.72.3.70;
}

host Sein {
    hardware ethernet 46:18:ea:e5:8d:1a;
    fixed-address 10.72.4.167;
}

host Stark {
    hardware ethernet 06:20:6f:d5:f0:96;
    fixed-address 10.72.4.168;
}
' > /etc/dhcp/dhcpd.conf

service isc-dhcp-server restart