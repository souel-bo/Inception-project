COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up:
	mkdir -p /home/sfyn/data/wordpress
	mkdir -p /home/sfyn/data/mariadb
	$(COMPOSE) up --build

down:
	$(COMPOSE) down



re:
	sudo rm -rf /home/sfyn/data/wordpress
	sudo rm -rf /home/sfyn/data/mariadb
	mkdir -p /home/sfyn/data/wordpress
	mkdir -p /home/sfyn/data/mariadb
	$(COMPOSE) down
	$(COMPOSE) up --build