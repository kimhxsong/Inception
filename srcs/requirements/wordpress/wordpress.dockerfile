FROM debian:buster

RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
	[ ! -d /var/www/html ]; \
	mkdir -p /var/www/html; \
	chown www-data:www-data /var/www/html; \
	chmod 777 /var/www/html

RUN set -eux; \
    apt-get update; \
    apt-get install -y \
      wget \
      php \
      php-fpm \
      php-json \
      php-mysqli \
    ; \
    rm -rf /var/lib/apt/lists/*;

RUN set -eux; \
  wget http://wordpress.org/latest.tar.gz; \
  tar -xzf latest.tar.gz -C /usr/src/; \
  rm latest.tar.gz; \
  mkdir -p /var/run/php-fpm/ /var/run/php/ /var/www/html/; \
  chown -R www-data:www-data \
    /usr/src/wordpress/ \
    /var/run/php-fpm/ \
    /var/run/php/ \
  ; \
  chmod 777 /var/run/php-fpm/ /var/run/php/; \
  ln -sf /usr/src/wordpress/ /var/www/html/;

VOLUME /var/www/html

COPY --chown=www-data:www-data wp-config-docker.php /usr/src/wordpress/wp-config.php
COPY ./tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN sed -i 's/\/run\/php\/php7.3-fpm.sock/0.0.0.0:9000/g' /etc/php/7.3/fpm/pool.d/www.conf

ENTRYPOINT [ "docker-entrypoint.sh" ]

EXPOSE 9000
CMD ["php-fpm"]
