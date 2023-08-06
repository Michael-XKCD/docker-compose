ARG VERSION=${VERSION}

FROM alpine:${VERSION}

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

RUN apk add docker

ENTRYPOINT ["/entrypoint.sh"]