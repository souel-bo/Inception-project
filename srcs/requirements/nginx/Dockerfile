FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx && \
    apt-get install -y openssl

COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

COPY ./tools/entry_point.sh /usr/local/bin/entry_point.sh

RUN chmod +x /usr/local/bin/entry_point.sh

ENTRYPOINT ["/usr/local/bin/entry_point.sh"]

CMD ["nginx", "-g", "daemon off;"]