#!/bin/bash

ln -sf /dev/stderr /var/log/nginx/error.log
ln -sf /dev/stdout /var/log/nginx/access.log

exec nginx -g 'daemon off;'
