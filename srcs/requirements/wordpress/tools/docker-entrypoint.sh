#!/usr/bin/env bash
set -Eeuo pipefail

echo "Establishing DB connection."

for i in {30..0}; do
		if mysql -u"${WORDPRESS_DB_USER}" \
             -p"${WORDPRESS_DB_PASSWORD}" \
             -D"${WORDPRESS_DB_NAME}" \
             -h"${WORDPRESS_DB_HOST}" <<<'SELECT 1' &> /dev/null; then
			break
		fi
		sleep 1
done

if [ "$i" = 0 ]; then
  echo "Establishing DB connection failed."
fi

echo "DB connection Established."

wpArgs=()
if [ "$(id -u)" = 0 ]; then
  wpArgs+=( '--allow-root' )
fi

docker_wp() {
  wp "${wpArgs}" "$@"
}

if [ ! -f "./wp-config.php" ]; then
  docker_wp config create \
  --dbname="${WORDPRESS_DB_NAME}" \
  --dbhost="${WORDPRESS_DB_HOST}":"${WORDPRESS_DB_PORT}" \
  --dbuser="${WORDPRESS_DB_USER}" \
  --dbpass="${WORDPRESS_DB_PASSWORD}" \
  --locale=ko_KR \
  --force

  docker_wp core install \
  --url="http://${DOMAIN_NAME}" \
  --title="${WORDPRESS_TITLE}" \
  --admin_user="${WORDPRESS_ADMIN_USER}" \
  --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
  --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
  --skip-email

   docker_wp user create $WORDPRESS_USER $WORDPRESS_USER_EMAIL \
    --role=author \
    --user_pass=$WORDPRESS_USER_PASSWORD \
    --path=/var/www/html
fi

echo "Wordrress settings done."

exec "$@" --nodaemonize
