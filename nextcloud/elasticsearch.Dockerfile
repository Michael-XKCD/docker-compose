LABEL version="${ES_VERSION}"

FROM docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}

RUN bin/elasticsearch-plugin install --batch ingest-attachment