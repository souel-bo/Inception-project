# Inception

*This project has been created as part of the 42 curriculum by [Your Name/Login].*

## Description
**Inception** is a foundational system administration project within the 42 curriculum designed to introduce developers to the concepts of virtualization, containerization, and microservice infrastructure orchestration. The core objective of the project is to configure a dedicated, multi-container web server stack running entirely from scratch inside a virtualization environment (such as an Ubuntu Linux Virtual Machine managed via VirtualBox).

Every single service in this ecosystem runs inside its own isolated container, generated using custom-designed Dockerfiles based strictly on a minimal Linux distribution (e.g., **Debian Bullseye** or **Alpine Linux**). To ensure complete configuration proficiency, the use of pre-built, ready-to-use Docker Hub images (such as standard `nginx`, `mariadb`, or `wordpress` packages) is strictly prohibited. Every configuration parameter, user right, system package dependency, and network rule must be manually specified, compiled, and integrated.

### Technical Stack Overview
The microservice infrastructure is orchestrated through a unified `docker-compose.yml` environment containing the following interconnected components:
- **NGINX Container:** Acts as the secure single-entry point to the system. It handles TLS traffic exclusively over port 443 via TLSv1.2 or TLSv1.3 cryptographic protocols, functioning as a reverse proxy for the web app.
- **WordPress & PHP-FPM Container:** Houses the application runtime logic, utilizing a PHP FastCGI Process Manager to interpret application requests cleanly without needing a bundled web server inside the same space.
- **MariaDB Container:** Serves as the relational database backbone, handling state persistence, post structures, security logs, and user schemas for the WordPress platform.
- **Private Internal Network:** A custom-bridge virtual network that binds these elements together, keeping storage and computation hidden from public access points.
- **Persistent Data Volumes:** Dedicated directories mapped onto the host computer's local filesystem to prevent state erasure across container maintenance routines.

---

## Architectural Comparison & Main Design Choices

### Main Design Choices
1. **Microservices Boundary Isolation:** Following modern infrastructure philosophies, each container executes exactly one primary process daemon (`nginx`, `php-fpm`, or `mysqld`). This minimizes the blast radius of any individual service failure and provides rigid security boundaries.
2. **Dynamic Entrypoint Initialization:** Instead of baking static configuration configurations directly into the immutable layers of the image, configuration injection is managed via bash initialization wrappers (`init.sh`) executed at runtime. This allows variables to be modified fluidly without invalidating the base build.
3. **Automated Provisioning via CLI:** WordPress is configured programmatically upon initial startup through `wp-cli` rather than human interaction via an installation wizard UI. This guarantees repeatable, reliable deployments.

### 1. Virtual Machines vs Docker
| Parameter | Virtual Machines (VMs) | Docker Containers |
| :--- | :--- | :--- |
| **Virtualization Layer** | Hardware-level virtualization managed via a Hypervisor (e.g., VirtualBox, VMware). | Operating System-level virtualization leveraging the host Linux kernel directly. |
| **Guest OS Requirement** | Requires a full copy of a guest operating system for every virtual instance. | No guest OS; shares the host kernel using kernel features like `namespaces` and `cgroups`. |
| **Resource Overhead** | High footprint (Requires dedicated, pre-allocated gigabytes of RAM and disk space). | Extremely lightweight (Megabytes of overhead, scaling dynamically with the application). |
| **Startup Speed** | Minutes (dependent on complete system boot cycles). | Seconds (equivalent to the time needed to launch a native host process). |
| **Isolation Strength** | Complete hardware isolation, offering highly secure boundaries. | Process-level isolation; kernel-sharing presents theoretical cross-container exploits. |
| **Inception Application** | A VM serves as the clean sandbox environment, hosting the base OS where Docker runs, isolating the entire project from the real host machine. | Docker handles the execution of individual application nodes within the VM sandbox, structuring clean microservices without bloated overhead. |

### 2. Secrets vs Environment Variables
- **Environment Variables (`.env`):** Passed into a running container as raw text strings visible to standard configuration lookups. While convenient for setting domain configurations, application adjustments, or debug modes, they remain vulnerable to local inspection. Any user with root-level access to the container engine can extract environment variables easily via `docker inspect` or by checking runtime process trees (`/proc`).
- **Secrets (Docker Secrets):** Designed specifically for high-stakes credentials like database master keys or SSL private passphrases. Secrets are decoupled from standard application text blocks, mounted dynamically into the target container container filesystem as temporary in-memory files (`/run/secrets/`), and never recorded into image caches or text environments.
- **Inception Application:** To respect the structural requirements of standard Docker Compose environments without Swarm extensions, sensitive credentials are isolated entirely inside a root `.env` file that is strictly blocked from the Git repository via `.gitignore`. 

### 3. Docker Network vs Host Network
- **Host Network Mode (`network_mode: "host"`):** Erases the networking boundary between the container and the host environment. The application inside the container binds directly to the host's network interfaces. For example, a database running on port 3306 inside the container is immediately accessible globally on port 3306 of the host, presenting extensive security risks and port collision conflicts.
- **Docker Custom Network (Bridge Mode):** Provisions an isolated, private virtual software switch managed by the Docker engine. Containers are assigned unique internal IPs and communicate inside the private bridge using automated internal DNS lookup names (e.g., `wordpress` pinging `mariadb`). External visibility is blocked unless explicitly bridged via a port forwarding declaration.
- **Inception Application:** The project employs a custom bridge network layout. This ensures that the MariaDB database and WordPress engine remain entirely closed off from external networks. NGINX functions as the absolute, single exposed portal mapping port 443 out to the host.

### 4. Docker Volumes vs Bind Mounts
- **Bind Mounts:** Connect an explicit file or folder pathway from the host system straight into a directory within the container (e.g., mounting `./nginx.conf` into `/etc/nginx/nginx.conf`). They depend entirely on the host machine maintaining an identical directory map, and can cause configuration breaks across different environments due to shifting user permissions (UID/GID mismatches).
- **Docker Volumes:** Fully decoupled abstractions maintained within an internal storage location controlled exclusively by the Docker daemon (`/var/lib/docker/volumes/`). They are more performant, independent of the host filesystem layout, and safely managed via the Docker CLI lifecycle tools.
- **Inception Application:** In accordance with the project criteria, named Docker volumes are explicitly mapped to specific local host storage paths (`/home/login/data/wordpress` and `/home/login/data/mariadb`). This configuration forces reliable state retention on the machine's disk, ensuring that database rows and application uploads persist seamlessly even if containers are destroyed or scrubbed.

---

## Instructions

### Prerequisites
Before compiling, you must set up your local host file redirection to support the custom domain. Append the following routing rule to your local `/etc/hosts` configuration:
```text
127.0.0.1    login.42.fr
```
*(Replace `login` with your actual 42 username format).*

### Compilation & Build Setup
1. Clone the project code to your local machine:
   ```bash
   git clone https://github.com/your-username/Inception.git && cd Inception
   ```
2. Populate the structural configuration credentials file (`.env`) at the root directory:
   ```bash
   cp srcs/.env.example .env
   # Edit .env using your preferred editor to adjust passwords
   nano .env
   ```
3. Initialize the persistent data storage directories on the host filesystem:
   ```bash
   mkdir -p /home/login/data/wordpress
   mkdir -p /home/login/data/mariadb
   ```

### Execution Controls via Makefile
The lifecycle of the stack is managed entirely through standard automation targets within the project `Makefile`:

- **Compile and Launch Stack:** Builds the custom Docker images from scratch and boots the container network in detached mode.
  ```bash
  make
  ```
- **Stop Stack:** Safely pauses and shuts down all active services without deleting runtime data.
  ```bash
  make down
  ```
- **Purge and Recompile:** Destroys all active nodes, cleans internal network systems, flushes images, and performs a complete rebuild from the ground up.
  ```bash
  make re
  ```
- **Total System Clean:** Completely cleans the project environment, including pruning inactive images and explicitly wiping all local host volume persistent data folders (`/home/login/data/`).
  ```bash
  make fclean
  ```

---

## Resources

### Reference Materials & Documentation
- **Docker Architecture and Build Guidelines:** [Docker Engine Reference Manual](https://docs.google.com/search?q=docker+documentation)
- **Compose Orchestration Specification:** [Compose V2 File Reference Guide](https://docs.docker.com/compose/)
- **NGINX Engine Optimization and Core SSL Mapping:** [NGINX Documentation Matrix](https://nginx.org/en/docs/)
- **MariaDB Administration and User Access Rules:** [MariaDB Knowledge Base Manuals](https://mariadb.com/kb/en/)
- **WordPress Automated Deployment Toolsets:** [WP-CLI Command Reference Library](https://make.wordpress.org/cli/handbook/)

### AI Usage Disclosure
- **Task Allocations:** Artificial Intelligence was leveraged to refine the structure of the data comparison tables, draft standard boilerplate boilerplate parameter mapping configurations for FastCGI stream headers, and structure the data flows for this README.
- **Targeted Code Blocks:** Validation of system signal handling wrappers inside the custom `mariadb/tools/init.sh` container script, and generation of the clean comparative markdown matrices inside this `README.md` file.