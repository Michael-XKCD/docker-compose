ARG VERSION=${VERSION}

FROM docker.elastic.co/elasticsearch/elasticsearch:${VERSION}

RUN bin/elasticsearch-plugin install --batch ingest-attachment