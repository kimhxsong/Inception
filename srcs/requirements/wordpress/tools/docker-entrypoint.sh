#!/bin/sh

mkdir -p /usr/share/webapps/

cd /usr/share/webapps/
wget http://wordpress.org/latest.tar.gz

tar -xzvf latest.tar.gz
rm latest.tar.gz

mkdir -p /var/www/html
ln -sf /usr/share/webapps/wordpress /var/www/html

exec /bin/sh