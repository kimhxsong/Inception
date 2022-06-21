#!/bin/bash

mysql << EOF
CREATE DATABASE ${MARIADB_DATABASE}
EOF

exec mysqld
