FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/entry_point.sh /usr/local/bin

RUN chmod +x /usr/local/bin/entry_point.sh

ENTRYPOINT ["/usr/local/bin/entry_point.sh"]

CMD ["mysqld", "--user=mysql"]