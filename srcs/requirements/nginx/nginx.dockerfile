FROM debian:buster

RUN set -ex; \
    apt-get update; \
    apt-get install -y nginx;

COPY ./conf/default.conf /etc/nginx/conf.d/
COPY ./tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]

EXPOSE 443
EXPOSE 80
CMD ["nginx"]