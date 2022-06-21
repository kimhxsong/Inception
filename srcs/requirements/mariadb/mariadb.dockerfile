FROM debian:buster

RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN set-ex; \
    apt-get update; \
    apt-get install -y procps; \
    rm -rf /var/lib/apt/lists/*;

COPY ./conf/my.cnf /etc/

RUN set -ex; \
    apt-get update; \
    apt-get install -y mariadb-server mariadb-client; \
    rm -rf /var/lib/mysql; \
    mkdir -p /var/lib/mysql /var/run/mysqld; \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld; \
    chmod 777 /var/run/mysqld; \
    find /etc/mysql/ -name '*.cnf' -print0 \
      | xargs -0 grep -lZE '^(bind-address|log|user\s)' \
      | xargs -rt -0 sed -Ei 's/^(bind-address|log|user\s)/#&/'; \
    rm -rf /var/lib/apt/lists/*;

RUN mysql_install_db

COPY ./tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]

EXPOSE 3306
CMD ["mysqld"]
