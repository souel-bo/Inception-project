#!/bin/sh

set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    echo "Starting temporary MariaDB server..."

    mysqld --user=mysql &

    until mysqladmin ping --silent; do
        echo "Waiting for MariaDB..."
        sleep 1
    done

    echo "Creating WordPress database..."

    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${WP_DB}\`;"

    echo "Creating WordPress user..."

    mysql -u root -e \
    "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

    echo "Granting privileges..."

    mysql -u root -e \
    "GRANT ALL PRIVILEGES ON \`${WP_DB}\`.* TO '${MYSQL_USER}'@'%';"

    echo "Setting root password..."

    mysql -u root -e \
    "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

    mysql -u root -e "FLUSH PRIVILEGES;"

    echo "Stopping temporary MariaDB server..."

    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

echo "Starting MariaDB..."

exec "$@"