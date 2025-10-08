# Nextcloud - Migrated to AIO

## Migration Notice

This Nextcloud deployment has been migrated to Nextcloud All-in-One (AIO) as recommended by the Nextcloud development team for Docker/Docker Compose deployments.

## Nextcloud All-in-One (AIO)

Repository: https://github.com/nextcloud/all-in-one

Nextcloud AIO is the official, recommended way to install and maintain Nextcloud using Docker. It provides:

- Official support: Maintained by Nextcloud developers
- Easy management: Built-in backup, update, and maintenance tools
- Better performance: Optimized configuration out-of-the-box
- Enhanced security: Automatic SSL certificates and security hardening
- Monitoring: Built-in health checks and logging

## Quick Start with AIO

```bash
# Run the AIO mastercontainer
docker run \
  --init \
  --sig-proxy=false \
  --name nextcloud-aio-mastercontainer \
  --restart always \
  --publish 80:80 \
  --publish 8080:8080 \
  --publish 8443:8443 \
  --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  nextcloud/all-in-one:latest
```

Then visit `https://localhost:8080` to complete the setup.

## Documentation

For detailed setup instructions and configuration options, visit the [Nextcloud AIO documentation](https://github.com/nextcloud/all-in-one#how-to-use-this).

---

Previous custom Docker Compose configuration removed in favor of the official AIO deployment method.
