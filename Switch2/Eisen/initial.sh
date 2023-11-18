#!/bin/bash
echo 'nameserver 10.72.1.3
nameserver 192.168.122.1' > /etc/resolv.conf

# Update package list

apt-get update
apt-get install nginx apache2-utils
apt-get install lynx
service nginx start

rm /etc/nginx/sites-available/default
rm /etc/nginx/sites-enabled/default

lb_config=$(cat <<EOF
    upstream myweb_robin {
        server 10.72.3.2;
        server 10.72.3.3;
        server 10.72.3.4;
    }

    upstream myweb_robin_weight {
        server 10.72.3.2 weight=1;
        server 10.72.3.3 weight=2;
        server 10.72.3.4 weight=4;
    }

    upstream myweb_robin1 {
        server 10.72.3.2;
        server 10.72.3.3;
        server 10.72.3.4;
    }

    upstream myweb_robin2 {
        server 10.72.3.2;
        server 10.72.3.3;
    }

    upstream myweb_robin3 {
        server 10.72.3.2;
        server 10.72.3.3;
        server 10.72.3.4;
    }

    upstream myweb_least_conn {
        least_conn;
        server 10.72.3.2;
        server 10.72.3.3;
        server 10.72.3.4;
    }

    upstream myweb_ip_hash {
        ip_hash;
        server 10.72.3.2;
        server 10.72.3.3;
        server 10.72.3.4;
    }

    upstream myweb_hash {
        hash $request_uri consistent;
        server 10.72.3.2;
        server 10.72.3.3;
        server 10.72.3.4;
    }


    server {
        listen 80;
        server_name granz.channel.it17.com;

        allow 10.72.3.69;
        allow 10.72.3.70;
        allow 10.72.4.167;
        allow 10.72.4.168;
        deny all;

        location /its {
            proxy_pass https://www.its.ac.id/;
        }

        location / {
            proxy_pass http://myweb_robin;

            auth_basic "Administrator's Area";
            auth_basic_user_file /etc/nginx/rahasiakita/.htpasswd;
        }

        location /first/ {
            proxy_pass http://myweb_robin1;
        }

        location /second/ {
            proxy_pass http://myweb_robin2;
        }

        location /third/ {
            proxy_pass http://myweb_robin3;
        }

        location /weight/ {
            proxy_pass http://myweb_robin_weight;
        }

        location /least_conn/ {
            proxy_pass http://myweb_least_conn;
        }

        location /ip_hash/ {
            proxy_pass http://myweb_ip_hash;
        }

        location /hash/ {
            proxy_pass http://myweb_hash;
        }

        location ~ /\.ht {
            deny all;
        }
error_log /var/log/nginx/eisen_error.log;
access_log /var/log/nginx/eisen_access.log;
    }
EOF
)

echo "$lb_config" > /etc/nginx/sites-available/granz.channel.it17.com

# Config No 18

echo 'upstream worker {
    server 10.72.4.2:8003;
    server 10.72.4.3:8002;
    server 10.72.4.4:8001;
}

server {
    listen 80;
    server_name riegel.canyon.it17.com www.riegel.canyon.it17.com;

    location / {
        proxy_pass http://worker;
    }
} 
' > /etc/nginx/sites-available/laravel-worker

ln -s /etc/nginx/sites-available/laravel-worker /etc/nginx/sites-enabled/laravel-worker

#ln -s /etc/nginx/sites-available/arjuna.it17.com /etc/nginx/sites-enabled
ln -s /etc/nginx/sites-available/granz.channel.it17.com /etc/nginx/sites-enabled

mkdir /etc/nginx/rahasiakita
htpasswd -c /etc/nginx/rahasiakita/.htpasswd netics

service nginx restart

# ab -n 100 -c 10 -p login.json -T application/json http://www.riegel.canyon.it17.com/api/auth/login