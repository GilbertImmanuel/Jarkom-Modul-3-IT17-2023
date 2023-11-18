#!/bin/bash

echo '
auto eth0
iface eth0 inet dhcp
hwaddress enter 26:90:6a:de:d0:0d
' > /etc/network/interfaces

# Update package list
apt-get update
apt install dnsutils
apt install lynx -y
apt install htop -y
apt install apache2-utils -y
apt-get install jq -y

echo '
{
  "username": "kelompokIT17",
  "password": "passwordIT17"
}' > register.json

# ab -n 100 -c 10 -p register.json -T application/json http://10.72.4.2:8003/api/auth/register

echo '
{
  "username": "kelompokIT17",
  "password": "passwordIT17"
}' > login.json

# ab -n 100 -c 10 -p login.json -T application/json http://10.72.4.2:8003/api/auth/login

# curl -X POST -H "Content-Type: application/json" -d @login.json http://10.72.4.2:8003/api/auth/login > login_output.txt