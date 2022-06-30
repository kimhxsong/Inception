FROM debian:buster

RUN set -ex; \
    apt-get update; \
    apt-get install -y nginx openssl;

ADD  ./certs/ /etc/nginx/self-signed/
COPY --chown=www-data:www-data ./conf/default /etc/nginx/sites-enabled/
COPY ./tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]

CMD ["nginx"]
