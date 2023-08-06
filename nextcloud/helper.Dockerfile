ARG VERSION=${VERSION}

FROM alpine:${VERSION}

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]