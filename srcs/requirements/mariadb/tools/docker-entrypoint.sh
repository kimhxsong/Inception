#!/bin/bash

set -eux

mysqld &
sleep 2
echo 1 > /dev/stderr

mysql << EOF
GRANT ALL PRIVILEGES ON *.* TO "root"@"localhost" IDENTIFIED BY "secret";
GRANT ALL PRIVILEGES ON *.* TO "root"@"%" IDENTIFIED BY "secret";
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO "wordpress"@"%" IDENTIFIED BY "secret";
FLUSH PRIVILEGES;
EOF

echo 2 > /dev/stderr
sleep 5;
mysqladmin shutdown -uroot -psecret

echo 3 > /dev/stderr
ps -ef > /dev/stderr

exec mysqld
ps -ef > /dev/stderr