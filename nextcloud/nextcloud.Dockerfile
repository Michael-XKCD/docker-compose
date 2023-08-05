ARG VERSION=${VERSION}

FROM nextcloud:${VERSION}

ENTRYPOINT chown -R :www-data /data && chmod -R g+rwx /data && chmod -R 0770 /data && /entrypoint.sh