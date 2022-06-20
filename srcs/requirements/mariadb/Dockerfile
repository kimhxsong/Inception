ARG DEBIAN_VERSION=buster
FROM debian:${DEBIAN_VERSION}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-get update && \
    apt-get install -y mariadb-server

RUN rm -rf /var/lib/mysql; \
    mkdir -p /var/lib/mysql /var/run/mysqld; \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld; \
    chmod 777 /var/run/mysqld;

RUN mysql_install_db;

HEALTHCHECK --start-period=5m \
  CMD mariadb -e 'SELECT @@datadir;' || exit 1

CMD ["mysqld"]