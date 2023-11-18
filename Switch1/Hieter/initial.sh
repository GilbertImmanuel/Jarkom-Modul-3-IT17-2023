#!/bin/bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# Update package list
apt-get update

# Install BIND9
apt-get install bind9 -y

# Add DNS zone configurations to /etc/bind/named.conf.local
echo '
zone "riegel.canyon.it17.com" {
  type master;
  file "/etc/bind/it17_modul3/riegel.canyon.it17.com";
};

zone "granz.channel.it17.com" {
  type master;
  file "/etc/bind/it17_modul3/granz.channel.it17.com";
};
' > /etc/bind/named.conf.local

mkdir -p /etc/bind/it17_modul3

echo ';
; BIND data file for local loopback interface
;
$TTL    2022100601
@       IN      SOA     riegel.canyon.it17.com. root.riegel.canyon.it17.com. (
                              2022100601         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      riegel.canyon.it17.com.
@       IN      A       10.72.2.3
www     IN      CNAME   riegel.canyon.it17.com.
' > /etc/bind/it17_modul3/riegel.canyon.it17.com

echo ';
; BIND data file for local loopback interface
;
$TTL    2022100601
@       IN      SOA     granz.channel.it17.com. root.granz.channel.it17.com. (
                              2022100601         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      granz.channel.it17.com.
@       IN      A       10.72.2.3
www     IN      CNAME   granz.channel.it17.com.
' > /etc/bind/it17_modul3/granz.channel.it17.com

echo '
options {
  directory "/var/cache/bind";
  forwarders {
    192.168.122.1;
  };
  allow-query{any;};

  listen-on-v6 { any; };
};
' > /etc/bind/named.conf.options

service bind9 restart
#echo "nameserver 10.72.2.2" > /etc/resolv.conf
#echo "nameserver 10.72.2.3" >> /etc/resolv.conf