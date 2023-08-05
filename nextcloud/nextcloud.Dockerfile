ARG VERSION=${VERSION}

FROM nextcloud:${VERSION}

COPY change-perms.sh /change-perms.sh

ENTRYPOINT ["/entrypoint.sh && /change-perms.sh"]