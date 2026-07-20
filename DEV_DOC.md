# Developer Documentation

This document explains how to set up, build and maintain the project.

---

# Prerequisites

The following software must be installed.

- Docker
- Docker Compose
- GNU Make

The project is intended to run inside a Linux virtual machine.

---

# Repository Structure

```
.
├── Makefile
├── README.md
└── srcs
    ├── docker-compose.yml
    ├── .env
    ├── secrets
    └── requirements
```

Each service has its own Dockerfile and initialization scripts.

---

# Configuration

Before starting the project, configure the environment variables.

```
srcs/.env
```

Example values:

- DOMAIN_NAME
- MYSQL_DATABASE
- MYSQL_USER
- WP_ADMIN_USER
- WP_USER

---

# Secrets

Passwords are stored separately from the main configuration.

MariaDB:

```
srcs/secrets/mariadb_credentials/db_credentials.txt
```

WordPress:

```
srcs/secrets/wordpress_credentials/wp_credentials.txt
```

---

# Persistent Directories

The project stores persistent data inside:

```
/home/sfyn/data
```

Required directories:

```
/home/sfyn/data/mariadb
/home/sfyn/data/wordpress
```

They are automatically created by the Makefile.

---

# Building the Project

Build every Docker image:

```bash
make
```

or

```bash
make up
```

Docker Compose performs the following operations:

1. Builds custom images.
2. Creates the Docker network.
3. Creates persistent volumes.
4. Starts MariaDB.
5. Starts WordPress.
6. Starts NGINX.

---

# Rebuilding

```bash
make re
```

---

# Stopping

```bash
make down
```

---

# Cleaning

```bash
make fclean
```

---

# Useful Docker Commands

Running containers

```bash
docker ps
```

All containers

```bash
docker ps -a
```

Docker images

```bash
docker images
```

Volumes

```bash
docker volume ls
```

Networks

```bash
docker network ls
```

Inspect container

```bash
docker inspect wordpress
```

Container logs

```bash
docker logs wordpress
```

Interactive shell

```bash
docker exec -it wordpress bash
```

---

# Persistent Data

MariaDB stores its database inside

```
/var/lib/mysql
```

mapped to

```
/home/sfyn/data/mariadb
```

WordPress stores its website files inside

```
/var/www/wordpress
```

mapped to

```
/home/sfyn/data/wordpress
```

Removing containers does not remove these directories, allowing the project state to persist across rebuilds.

---

# Development Workflow

1. Modify the Dockerfile or configuration.
2. Rebuild the affected image.
3. Restart the stack.
4. Verify the logs.
5. Test the website.
6. Confirm database connectivity.

---

# Debugging

Container status

```bash
docker ps -a
```

Logs

```bash
docker logs <container_name>
```

Container shell

```bash
docker exec -it <container_name> bash
```

Database

```bash
docker exec -it mariadb bash
mariadb -u root -p
```

WordPress

```bash
docker exec -it wordpress bash
```

NGINX

```bash
docker exec -it nginx bash
```