ARG VERSION=${VERSION}

FROM nextcloud:${VERSION}

COPY change-perms.sh /

RUN chmod +x /change-perms.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh", "/change-perms.sh"]