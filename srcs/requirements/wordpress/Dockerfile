FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-cli \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-xmlrpc \
    php7.4-soap \
    php7.4-intl \
    php7.4-zip \
    mariadb-client \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/wordpress /run/php

WORKDIR /var/www/wordpress

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["php-fpm7.4", "-F"]