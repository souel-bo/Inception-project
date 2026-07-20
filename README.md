# Inception

*This project has been created as part of the 42 curriculum by souel-bo.*

---

# Description

**Inception** is a system administration project from the 42 curriculum whose goal is to introduce students to modern containerized infrastructures using Docker.

The objective is to build a complete web application stack composed of multiple isolated services communicating through a private Docker network. Every service must be built from a custom Dockerfile without using pre-built application images from Docker Hub. This approach encourages understanding of Linux administration, networking, process isolation, persistent storage, TLS configuration, and service orchestration.

This project deploys a secure WordPress website composed of three independent containers:

- **NGINX**
- **WordPress + PHP-FPM**
- **MariaDB**

The entire infrastructure is managed by Docker Compose and automatically configured during startup without requiring any manual interaction.

---

# Project Architecture

```
                        Internet
                            │
                      HTTPS (443)
                            │
                     +---------------+
                     |     NGINX     |
                     | TLS 1.2/1.3   |
                     +---------------+
                            │
                        FastCGI
                            │
               +-------------------------+
               | WordPress + PHP-FPM     |
               +-------------------------+
                            │
                      MySQL Protocol
                            │
                     +---------------+
                     |   MariaDB     |
                     +---------------+

                 Docker Bridge Network
                  (inception_network)
```

Only the NGINX container is accessible from outside the Docker network.

WordPress communicates exclusively with MariaDB through Docker's internal DNS service.

---

# Project Structure

```
.
├── Makefile
├── README.md
└── srcs
    ├── docker-compose.yml
    ├── .env
    ├── secrets
    │   ├── mariadb_credentials
    │   └── wordpress_credentials
    └── requirements
        ├── mariadb
        │   ├── Dockerfile
        │   ├── conf
        │   └── tools
        ├── nginx
        │   ├── Dockerfile
        │   ├── conf
        │   └── tools
        └── wordpress
            ├── Dockerfile
            ├── conf
            └── tools
```

---

# Services

## NGINX

NGINX acts as the single entry point of the infrastructure.

Responsibilities:

- Terminates HTTPS connections
- Uses TLS 1.2 / TLS 1.3
- Serves static WordPress files
- Forwards PHP requests to PHP-FPM
- Exposes only port **443**

No other container is reachable directly from outside the Docker network.

---

## WordPress + PHP-FPM

The WordPress container contains:

- PHP-FPM
- WP-CLI
- WordPress core files

During the first startup the entrypoint script:

1. Waits until MariaDB is ready.
2. Downloads WordPress using WP-CLI.
3. Generates `wp-config.php`.
4. Connects to MariaDB.
5. Installs WordPress automatically.
6. Creates the administrator account.
7. Creates a regular user.
8. Starts PHP-FPM in the foreground.

Because of this initialization process, the WordPress installation page never appears during evaluation.

---

## MariaDB

MariaDB provides persistent storage for the application.

During the first startup the initialization script:

- Creates the database.
- Creates the database user.
- Assigns the user's privileges.
- Configures the root password.
- Stores all data inside the persistent Docker volume.

Subsequent container restarts reuse the existing database without performing initialization again.

---

# Persistent Storage

Two persistent volumes are used.

```
/home/sfyn/data
├── mariadb
└── wordpress
```

These directories remain on the host machine even if the containers are destroyed.

This guarantees that:

- uploaded files remain available
- WordPress configuration persists
- database contents survive container recreation

---

# Docker Network

All services communicate through a custom bridge network.

```
                inception_network

        nginx
           │
           │
     wordpress
           │
           │
        mariadb
```

Docker provides an internal DNS server.

Instead of using IP addresses, services communicate using their service names.

Example:

```
wordpress  --->  mariadb
```

Docker automatically resolves the hostname `mariadb` to the correct container.

---

# Main Design Choices

## One Service per Container

Each container executes exactly one primary process.

| Container | Main Process |
|----------|--------------|
| NGINX | nginx |
| WordPress | php-fpm |
| MariaDB | mysqld |

This follows Docker's philosophy and makes debugging, maintenance, and monitoring much easier.

---

## Automatic WordPress Installation

Instead of configuring WordPress manually through the browser, WP-CLI performs the installation automatically during the first startup.

Advantages:

- repeatable deployment
- faster startup
- no manual configuration
- deterministic evaluation

---

## Environment Variables

Configuration values are injected at runtime through environment variables loaded from:

- `.env`
- credentials files

This avoids hardcoding configuration values inside Docker images.

---

# Technical Comparisons

## Virtual Machines vs Docker

| Virtual Machine | Docker |
|----------------|---------|
| Virtualizes hardware | Virtualizes the operating system |
| Requires a complete guest OS | Shares the host kernel |
| Higher resource consumption | Lightweight |
| Slower startup | Starts within seconds |
| Larger disk usage | Smaller images |
| Better hardware isolation | Better application portability |

For this project Docker runs inside a Linux virtual machine. The VM isolates the entire development environment, while Docker isolates each application service.

---

## Secrets vs Environment Variables

Environment variables store configuration values that applications can read during execution.

Examples:

- database name
- domain name
- usernames

Sensitive values such as passwords should never be hardcoded inside Dockerfiles.

In this project, credentials are separated from the application configuration by storing passwords in dedicated credential files that are ignored by Git. This keeps sensitive information out of the source code repository while allowing the containers to receive the values at runtime.

---

## Docker Network vs Host Network

**Host Network**

- Shares the host network stack.
- No network isolation.
- Containers become directly accessible.

**Docker Bridge Network**

- Private virtual network.
- Internal DNS resolution.
- Containers communicate securely.
- Only explicitly published ports are exposed.

This project uses a custom bridge network because it isolates MariaDB and WordPress from external access while allowing communication between services.

---

## Docker Volumes vs Bind Mounts

### Bind Mount

A bind mount maps an existing directory from the host directly into a container.

Example:

```
/home/sfyn/data/mariadb
        │
        ▼
/var/lib/mysql
```

The host controls the storage location.

### Docker Volume

A Docker volume is managed by Docker itself.

Docker decides where the data is stored.

### Project Choice

This project uses named volumes backed by host directories located in:

```
/home/sfyn/data
```

This satisfies the project requirements while ensuring data persistence after container removal.