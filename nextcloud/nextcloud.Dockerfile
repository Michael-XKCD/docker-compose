ARG VERSION=${VERSION}

FROM nextcloud:${VERSION}

COPY change-perms.txt /

RUN cat /change-perms.txt >> /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN rm /change-perms.txt