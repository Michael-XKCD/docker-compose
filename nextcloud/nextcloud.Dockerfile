ARG VERSION=${VERSION}

FROM nextcloud:${VERSION}

COPY change-perms.sh /

COPY run_scripts.sh /

RUN chmod +x /change-perms.sh

RUN chmod +x /run_scripts.sh

ENTRYPOINT ["/run_scripts.sh"]