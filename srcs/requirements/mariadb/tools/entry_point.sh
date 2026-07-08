#!/bin/sh

set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

mysql_root() {
    mysql -u root "$@" 2>/dev/null || mysql -u root -p"${MYSQL_ROOT_PASSWORD}" "$@"
}

initialize_database() {
    echo "Creating WordPress database..."

    mysql_root <<EOF
CREATE DATABASE IF NOT EXISTS \`${WP_DB}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${WP_DB}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
}

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

echo "Starting temporary MariaDB server..."

mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &

until mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent; do
    echo "Waiting for MariaDB..."
    sleep 1
done

initialize_database

echo "Stopping temporary MariaDB server..."

mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "Starting MariaDB..."

exec "$@"