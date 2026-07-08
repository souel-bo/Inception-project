#!/bin/sh

set -e

mkdir -p /run/php

cd /var/www/wordpress


until mysqladmin ping \
    -h mariadb \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    --silent
do
    echo "Waiting for MariaDB..."
    sleep 1
done

if [ ! -f wp-config.php ]; then

    echo "Downloading WordPress..."
    wp core download --force --allow-root

    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${WP_DB}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root

fi

if ! wp core is-installed --allow-root; then
    echo "Installing WordPress..."
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
fi

if ! wp user get "${WP_USER}" --allow-root >/dev/null 2>&1; then
    echo "Creating additional user..."
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
fi

echo "Starting PHP-FPM..."

exec "$@"