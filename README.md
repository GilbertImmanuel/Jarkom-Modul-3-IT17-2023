# # Jarkom-Modul-3-IT17-2023

Laporan resmi dari modul ketiga mata kuliah Komunikasi Data dan Jaringan Komputer IT ITS 2023.

## Authors

| NRP        | Nama                       |
| :--------  | :------------------------  |
| 5027211038 | Ahnaf Musyaffa             |
| 5027211056 | Gilbert Immanuel Hasiholan |


## Penjelasan

### Soal 13

> Semua data yang diperlukan, diatur pada Denken dan harus dapat diakses oleh Frieren, Flamme, dan Fern.

Untuk menyelesaikan permasalahan ini, perlu kita buka terlebih dahulu Database Server, yakni node `Denken` dan mengkonfigurasikannya sebagai berikut

```sh
echo '# This group is read both by the client and the server
# use it for options that affect everything
[client-server]

# Import all .cnf files from configuration directory
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mariadb.conf.d/

# Options affecting the MySQL server (mysqld)
[mysqld]
skip-networking=0
skip-bind-address
' > /etc/mysql/my.cnf
```

Setelah itu perlu kita akses `/etc/mysql/mariadb.conf.d/50-server.cnf` dan mengubah value [bind-address] menjadi 0.0.0.0.

```sh 
bind-address            = 0.0.0.0
```

Kemudian lakukan restart pada mysql seperti berikut `service mysql restart` dan jalankan perintah sebagai berikut:

```sh
mysql -u root -p

CREATE USER 'kelompokit17'@'%' IDENTIFIED BY 'passwordit17';
CREATE USER 'kelompokit17'@'localhost' IDENTIFIED BY 'passwordit17';
CREATE DATABASE dbkelompokit17;
GRANT ALL PRIVILEGES ON *.* TO 'kelompokit17'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'kelompokit17'@'localhost';
FLUSH PRIVILEGES;
```

Dimana akan membuat sebuah user baru dan database baru.\
![Nomor13](images/Nomor13_MariaDB.png)

Jika semuanya sudah dijalankan dengan benar, maka database tersebut dapat dicek oleh Laravel Worker `Frieren`, `Flamme`, maupun `Fern` seperti berikut:\
![Nomor13_Frieren](images/Nomor13_Frieren.png)
![Nomor13_Flamme](images/Nomor13_Flamme.png)

### Soal 14

> Frieren, Flamme, dan Fern memiliki Riegel Channel sesuai dengan quest guide berikut. Jangan lupa melakukan instalasi PHP8.0 dan Composer

Sebelum menghadapi permasalahan ini, perlu terlebih dahulu melakukan setup pada Laravel Worker yang ingin digunakan.

```sh
apt-get update
apt-get install lynx -y
apt-get install mariadb-client -y
```

#### Instalasi dan setup php8.0 dan nginx

```sh
apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list
apt-get install wget
wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -
apt-get update
apt-get install php8.0-mbstring php8.0-xml php8.0-cli   php8.0-common php8.0-intl php8.0-opcache php8.0-readline php8.0-mysql php8.0-fpm php8.0-curl unzip wget -y

apt-get update
apt-get install nginx -y

service nginx start
service php8.0-fpm start
```

#### Instalasi Composer
```sh
wget https://getcomposer.org/download/2.0.13/composer.phar
chmod +x composer.phar
mv composer.phar /usr/bin/composer
composer -V
```

Selanjutnya dilakukan instalasi `git` dan cloning dari [resource](https://github.com/martuafernando/laravel-praktikum-jarkom) yang diberikan serta install composer pada direktori `laravel-praktikum-jarkom`.

```sh
apt-get install git -y

git clone https://github.com/martuafernando/laravel-praktikum-jarkom.git
mv laravel-praktikum-jarkom /var/www/laravel-praktikum-jarkom

cd /var/www/laravel-praktikum-jarkom
composer update
composer install
```

Setelah melakukan clone pada resource tersebut. Sekarang lakukan konfigurasi sebagai berikut pada masing-masing worker

```sh
mv .env.example .env

echo '
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=10.72.2.2
DB_PORT=3306
DB_DATABASE=dbkelompokit17
DB_USERNAME=kelompokit17
DB_PASSWORD=passwordit17

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"' > /var/www/laravel-praktikum-jarkom/.env

php artisan migrate:fresh
php artisan db:seed --class=AiringsTableSeeder
php artisan key:generate
php artisan jwt:secret
php artisan storage:link
```

Selanjutnya lakukan konfigurasi nginx pada masing-masing Laravel Worker. Untuk port yang digunakan bebas, namun dalam kasus kita ini bentuknya seperti ini
```sh
10.72.4.4:8001; # Fern 
10.72.4.3:8002; # Flamme
10.72.4.2:8003; # Frieren
```

Dan konfigurasinya seperti berikut:

```sh
echo '
server {

    listen [Port Worker];

    root /var/www/laravel-praktikum-jarkom/public;

    index index.php index.html index.htm;
    server_name _;

    location / {
            try_files $uri $uri/ /index.php?$query_string;
    }

    # pass PHP scripts to FastCGI server
    location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
    }

location ~ /\.ht {
            deny all;
    }

    error_log /var/log/nginx/jarkom_error.log;
    access_log /var/log/nginx/jarkom_access.log;
}' > /etc/nginx/sites-available/laravel-worker

ln -s /etc/nginx/sites-available/laravel-worker /etc/nginx/sites-enabled/

chown -R www-data.www-data /var/www/laravel-praktikum-jarkom/

service nginx restart
service php8.0-fpm start
```

Jika sudah melakukan konfigurasi terhadap setiap Laravel Worker. Dapat dilakukan testing seperti berikut

```sh
lynx localhost:[PORT]
```

Dimana hasil yang didapatkan akan seperti ini.\
![Nomor14](images/Nomor14.png)

### Soal 15

> Riegel Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada grimoire.\ Untuk POST /auth/register

Pada permasalahan ini, diperlukan melakukan testing menggunakan Apache Benchmark pada salah satu worker saja. Disini kita akan menggunakan Laravel Worker `Frieren` yang akan dites pada client `Revolte`. Sebelum dilakukan testing, kita menggunakan bantuan file `.json` yang akan digunakan sebagai body yang akan dikirim pada endpoint `/api/auth/register` seperti berikut.

```sh
echo '
{
  "username": "kelompokIT17",
  "password": "passwordIT17"
}' > register.json
```

Lalu menjalankan command berikut pada node client `Revolte`

```sh
ab -n 100 -c 10 -p register.json -T application/json http://10.72.4.2:8003/api/auth/register
```

Hasilnya menunjukkan error dalam pengiriman sebanyak 100 request dengan request yang diproses sebanyak 54 dan 46 request yang tidak diproses.
![Nomor15](images/Nomor15.png)

### Soal 16

> Riegel Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada grimoire.\ Untuk POST /api/auth/login

Cukup mirip seperti persoalan sebelumnya namun kali ini akan melakukan pengiriman pada endpoint `/api/auth/login`. Disini kita tetap menggunakan Laravel Worker `Frieren` dan client `Revolte`. Sama seperti sebelumnya kita menggunakan file `.json` seperti berikut

```sh
echo '
{
  "username": "kelompokIT17",
  "password": "passwordIT17"
}' > login.json
```

Lalu menjalankan command berikut pada node client `Revolte`

```sh
ab -n 100 -c 10 -p login.json -T application/json http://10.72.4.2:8003/api/auth/login
```

Hasilnya menunjukkan error dalam pengiriman sebanyak 100 request dengan request yang diproses sebanyak 5 dan 95 request yang tidak diproses.
![Nomor16](images/Nomor16.png)

### Soal 17

> Riegel Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada grimoire.\ Untuk GET /api/me

Pada persoalan ini kita tetap menggunakan Laravel Worker `Frieren` dan client `Revolte`.  Sebelum dilakukan testing, ada beberapa konfigurasi yang harus disiapkan.

Pertama perlu mendapatkan tokennya sebelum mengakses endpoint `/api/me`

```sh
curl -X POST -H "Content-Type: application/json" -d @login.json http://10.72.4.2:8003/api/auth/login > login_output.txt
```

Setelah itu jalankan perintah berikut untuk melakukan testing

```sh
ab -n 100 -c 10 -H "Authorization: Bearer $token" http://10.72.4.2:8003/api/me
```

Hasilnya menunjukkan error dalam pengiriman sebanyak 100 request dengan request yang diproses sebanyak 62 dan 38 request yang tidak diproses.
![Nomor17](images/Nomor17.png)

### Soal 18
> Untuk memastikan ketiganya bekerja sama secara adil untuk mengatur Riegel Channel maka implementasikan Proxy Bind pada Eisen untuk mengaitkan IP dari Frieren, Flamme, dan Fern

Untuk menyelesaikan permasalahan ini, perlu dilakukan setup terlebih dahulu.

```sh
apt-get update
apt-get install nginx apache2-utils
apt-get install lynx
service nginx start
```

Setelah itu, dapat dilakukan konfigurasi nginx untuk membagi rata beban kerja worker seperti berikut. Perlu diperhatikan agar konfigurasi ini tidak bertabrakan dengan konfigurasi load balancer untuk php worker.

```sh
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

service nginx restart
```

Setelah konfigurasi pada load balancer pada Eisen, maka dapat dilakukan testing pada client `Revolte` dengan menjalankan command berikut

```sh
ab -n 100 -c 10 -p login.json -T application/json http://www.riegel.canyon.it17.com/api/auth/login
```
Hasilnya akan seperti berikut
![Nomor18](images/Nomor18.png)

**Fern**
![Nomor18_Fern](images/Nomor18_Fern.png)

**Flamme**
![Nomor18_Flamme](images/Nomor18_Flamme.png)

**Frieren**
![Nomor18_Frieren](images/Nomor18_Frieren.png)