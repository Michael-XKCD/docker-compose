ARG VERSION=${VERSION}

FROM nextcloud:${VERSION}

COPY change-perms.sh /docker-entrypoint-hooks.d/before-starting/change-perms.sh