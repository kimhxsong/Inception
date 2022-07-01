#!/bin/bash
set -eo pipefail
shopt -s nullglob

red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
end=$'\e[0m'

log_color() {
	local color="$1"
	local type="$2"; shift
	printf "$color"'%s [%s] [Entrypoint]: %s\n' "$(date --rfc-3339=seconds)" "$type" "$*""${end}"
}

log_note() {
	log_color "${grn}" NOTE "$@"
}

log_warn() {
	log_color "${yel}" WARN "$@" >&2
}

log_error() {
	log_color "${red}" ERROR "$@" >&2
	exit 1
}

_is_sourced() {
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

verify_root_password() {
	if [ -z "$MARIADB_ROOT_PASSWORD" ] && [ -z "$MYSQL_ROOT_PASSWORD" ]; then
		log_error $'[MARIADB|MYSQL]_ROOT_PASSWORD is empty.'
	fi
}

init_db() {
	log_note "Initializing database files"

	installArgs=(--datadir="$DATADIR" --rpm \
    --auth-root-authentication-method=normal --skip-test-db )
	mysql_install_db "${installArgs[@]}" "${@:2}" \
		--default-time-zone=SYSTEM --enforce-storage-engine= \
		--skip-log-bin \
		--expire-logs-days=0 \
		--loose-innodb_buffer_pool_load_at_startup=0 \
		--loose-innodb_buffer_pool_dump_at_shutdown=0
	mysql_install_db

	log_note "Database files initialized"
}

_verboseHelpArgs=(
	--verbose --help
	--log-bin-index="$(mktemp -u)"
)

check_config() {
	local toRun=( "$@" "${_verboseHelpArgs[@]}" ) errors
	if ! errors="$("${toRun[@]}" 2>&1 >/dev/null)"; then
		log_error $'mariadbd failed while attempting to check config\n\tcommand was: '"${toRun[*]}"$'\n\t'"$errors"
	fi
}

exec_client() {
	if [ -n "$MYSQL_DATABASE" ]; then
		set -- --database="$MYSQL_DATABASE" "$@"
	fi
	mysql --protocol=socket -uroot -hlocalhost --socket="${SOCKET}" "$@"
}

run_sql() {
	if [ '--dont-use-mysql-root-password' = "$1" ]; then
		shift
		MYSQL_PWD='' exec_client "$@"
	else
		MYSQL_PWD=$MYSQL_ROOT_PASSWORD exec_client "$@"
	fi
}

temp_server_start() {
	log_note "Starting temporary server"

	"$@" --skip-networking --socket="${SOCKET}" --wsrep_on=OFF \
		--expire-logs-days=0 \
		--skip-log-error \
		--loose-innodb_buffer_pool_load_at_startup=0 &
	log_note "Waiting for server startup"

	extraArgs=()
	if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
		extraArgs+=( '--dont-use-mysql-root-password' )
	fi
	local i
	for i in {30..0}; do
		if run_sql "${extraArgs[@]}" --database=mysql <<<'SELECT 1' &> /dev/null; then
			break
		fi
		sleep 1
	done

	if [ "$i" = 0 ]; then
		log_error "Unable to start server."
	fi

	log_note "Temporary server started."
}

setup_db() {
	log_note "Setting up root and user passwords"
	mysql <<- EOSQL
	CREATE USER IF NOT EXISTS root@localhost IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
	SET PASSWORD FOR root@localhost = PASSWORD('${MYSQL_ROOT_PASSWORD}');
	GRANT ALL ON *.* TO root@localhost WITH GRANT OPTION;
	CREATE USER IF NOT EXISTS root@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
	SET PASSWORD FOR root@'%' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
	GRANT ALL ON *.* TO root@'%' WITH GRANT OPTION;
	CREATE USER IF NOT EXISTS ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
	SET PASSWORD FOR ${MYSQL_USER}@'%' = PASSWORD('${MYSQL_PASSWORD}');
	CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
	GRANT ALL ON ${MYSQL_DATABASE}.* TO ${MYSQL_USER}@'%';
	EOSQL
}

mysqld_get_config() {
	local conf="$1"; shift
	"$@" "${_verboseHelpArgs[@]}" 2>/dev/null \
		| awk -v conf="$conf" '$1 == conf && /^[^ \t]/ { sub(/^[^ \t]+[ \t]+/, ""); print; exit }'
}

setup_env() {
	log_note "Setting DATABASE environment variables"

	declare -g DATADIR SOCKET
	DATADIR="$(mysqld_get_config 'datadir' "$@")"
	SOCKET="$(mysqld_get_config 'socket' "$@")"

	declare -g DATABASE_ALREADY_EXISTS
	if [ -d "$DATADIR/mysql" ]; then
		DATABASE_ALREADY_EXISTS='true'
	fi
}

temp_server_stop() {
	log_note "Stopping temporary server"

	if ! MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysqladmin shutdown -uroot --socket="${SOCKET}"; then
		log_error "Unable to shut down server."
	fi

	log_note "Temporary server stopped"
}

_main() {
	if [ "$1" == 'mariadbd' ] || [ "$1" == 'mysqld' ]; then
		log_note "Entrypoint script for MariaDB Server started."

		verify_root_password
		check_config "$@"
		setup_env "$@"

		if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
			init_db "$@"
			temp_server_start "$@"
			setup_db "$@"
			temp_server_stop "$@"
		fi
	fi
	exec "$@"
}

if ! _is_sourced; then
	_main "$@"
else
	log_error "Entrypoint script must not be sourced."
fi
