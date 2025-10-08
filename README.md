# Docker Compose Collections

> 🐳 A curated collection of production-ready Docker Compose configurations for self-hosted applications and development environments.

## 📋 Table of Contents

- [Available Services](#available-services)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Network Architecture](#network-architecture)
- [Environment Variables](#environment-variables)
- [Maintenance](#maintenance)
- [Contributing](#contributing)

## 🚀 Available Services

| Service | Description | Status | Web UI |
|---------|-------------|--------|--------|
| **[Android Emulator](./android-emulator/)** | Headless Android emulator for testing | ✅ Active | `http://localhost:6080` |
| **[Immich](./immich/)** | High-performance photo & video management | ✅ Active | `http://localhost:2283` |
| **[NPM](./NPM/)** | Nginx Proxy Manager (Internal/External) | ✅ Active | `http://localhost:81` |
| **[WordPress](./wordpress/)** | WordPress with MySQL (mcmurray.tech) | ✅ Active | Configured domain |
| **[Nextcloud](./nextcloud/)** | ⚠️ Migrated to AIO | 🔄 See folder | - |

## 📋 Prerequisites

- **Docker Engine** >= 20.10.0
- **Docker Compose** >= 2.0.0
- **Available Ports**: Check each service's compose file
- **System Requirements**: Minimum 2GB RAM, 10GB storage

### Installation Check

```bash
# Verify Docker installation
docker --version
docker compose version

# Ensure Docker daemon is running
docker info
```

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone git@github.com:Michael-XKCD/docker-compose.git
cd docker-compose
```

### 2. Choose a Service

```bash
# Navigate to desired service
cd immich  # or android-emulator, NPM, etc.

# Start the service
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### 3. Environment Variables

Most services require environment variables. Create `.env` files as needed:

```bash
# Example for NPM
echo "NPM_VERSION=latest" > NPM/.env
```

## 🌐 Network Architecture

This collection uses a hybrid networking approach:

- **`proxynet`** - External network for reverse proxy connectivity
- **`backend`** - Internal networks for service isolation
- **`br0`** - Bridge network for internal proxy manager

```bash
# Create external networks (run once)
docker network create proxynet
docker network create br0
```

## ⚙️ Environment Variables

Common environment variables across services:

| Variable | Description | Default |
|----------|-------------|----------|
| `TZ` | Timezone | `America/Los_Angeles` |
| `PUID/PGID` | User/Group IDs | `1000/1000` |
| `*_VERSION` | Image versions | `latest` |

## 🔧 Maintenance

### Updates

```bash
# Pull latest images
docker compose pull

# Restart with new images
docker compose up -d

# Remove old images
docker image prune
```

### Backups

```bash
# Backup volumes (example for Immich)
docker run --rm -v immich_pgdata:/data -v $(pwd):/backup ubuntu tar czf /backup/immich-backup.tar.gz /data

# List all volumes
docker volume ls | grep -E '(immich|wordpress|npm)'
```

### Monitoring

```bash
# Resource usage
docker stats

# Service health
docker compose ps

# Logs with timestamp
docker compose logs -t -f --tail=100
```

## 🛡️ Security Considerations

- **Reverse Proxy**: Use NPM for SSL termination
- **Networks**: Services use internal networks where possible
- **Secrets**: Store sensitive data in `.env` files (git-ignored)
- **Updates**: Regularly update images for security patches

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request

### Adding New Services

1. Create service directory
2. Add `docker-compose.yml`
3. Include service-specific `README.md`
4. Update main README table
5. Test deployment

## 📚 Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Best Practices](https://docs.docker.com/develop/best-practices/)
- [Networking Guide](https://docs.docker.com/network/)

---

**Last Updated**: October 2024  
**Maintainer**: [@Michael-XKCD](https://github.com/Michael-XKCD)