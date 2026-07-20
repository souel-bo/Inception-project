# User Documentation

This document explains how to use and manage the Inception project after it has been installed.

---

# Services

The project provides three services running inside separate Docker containers.

| Service | Description |
|----------|-------------|
| NGINX | Receives HTTPS requests from clients and forwards PHP requests to WordPress. |
| WordPress | Runs the website using PHP-FPM. |
| MariaDB | Stores all WordPress data including users, posts, settings and comments. |

These services communicate through a private Docker network.

---

# Starting the Project

To build and start the complete infrastructure:

```bash
make
```

or

```bash
make up
```

Docker Compose will:

- Build every image
- Create the Docker network
- Create persistent volumes
- Start MariaDB
- Start WordPress
- Start NGINX

---

# Stopping the Project

Stop all running containers:

```bash
make down
```

Containers will stop while preserving all stored data.

---

# Rebuilding the Project

To rebuild every image:

```bash
make re
```

---

# Cleaning the Project

To remove containers, images and persistent data:

```bash
make fclean
```

---

# Accessing the Website

Open your browser and navigate to:

```
https://souel-bo.42.fr
```

The website is only accessible through HTTPS.

HTTP access is disabled.

---

# Accessing the WordPress Administration Panel

Navigate to:

```
https://souel-bo.42.fr/wp-admin
```

Log in using the administrator credentials configured during installation.

---

# Credentials

Project configuration is divided into two categories.

## Environment Variables

General configuration is stored inside:

```
srcs/.env
```

Examples:

- domain name
- database name
- usernames
- website title

---

## Secret Credentials

Passwords are stored separately.

MariaDB:

```
srcs/secrets/mariadb_credentials/db_credentials.txt
```

WordPress:

```
srcs/secrets/wordpress_credentials/wp_credentials.txt
```

These files should never be committed to version control.

---

# Checking Container Status

List running containers:

```bash
docker ps
```

Show all containers:

```bash
docker ps -a
```

---

# Viewing Logs

NGINX

```bash
docker logs nginx
```

WordPress

```bash
docker logs wordpress
```

MariaDB

```bash
docker logs mariadb
```

---

# Checking the Database

Enter the MariaDB container:

```bash
docker exec -it mariadb bash
```

Login:

```bash
mariadb -u root -p
```

List databases:

```sql
SHOW DATABASES;
```

Select WordPress database:

```sql
USE wordpress;
```

Show tables:

```sql
SHOW TABLES;
```

---

# Verifying the Website

The following conditions indicate that the project is working correctly.

- NGINX container is running.
- WordPress container is running.
- MariaDB container is running.
- https://souel-bo.42.fr loads successfully.
- WordPress installation page does not appear.
- Database contains WordPress tables.