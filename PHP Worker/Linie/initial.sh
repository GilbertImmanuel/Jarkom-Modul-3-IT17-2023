#!/bin/bash

# Add nameserver to /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

# Update package list

apt-get update
apt install nginx
apt install zip
apt install php php-fpm -y

wget --no-check-certificate 'https://drive.google.com/u/0/uc?id=1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1&export=download' -O web-asset

mkdir /var/www/granz.channel.it17.com

unzip -o web-asset
mv ~/modul-3/* /var/www/granz.channel.it17.com
rm -rf web-asset modul-3

server_config=$(cat <<EOF
server {
    listen 80;
    root /var/www/granz.channel.it17.com;
    index index.php index.html index.htm;
    server_name _;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }

    error_log /var/log/nginx/abimanyu.log;
    access_log /var/log/nginx/abimanyu.log;
}
EOF
)

output_file="/etc/nginx/sites-available/granz.channel.it17.com"
echo "$server_config" > "$output_file"

rm /etc/nginx/sites-available/default
rm /etc/nginx/sites-enabled/default

ln -s /etc/nginx/sites-available/granz.channel.it17.com /etc/nginx/sites-enabled

service nginx restart
service php7.3-fpm start