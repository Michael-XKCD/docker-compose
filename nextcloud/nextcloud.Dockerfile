ARG VERSION=${VERSION}

FROM nextcloud:${VERSION}

# COPY change-perms.sh /

# RUN chmod +x /change-perms.sh

# CMD ["/change-perms.sh"]