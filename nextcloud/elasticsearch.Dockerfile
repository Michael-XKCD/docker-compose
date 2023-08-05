FROM $REPO/elasticsearch:$VERSION

RUN bin/elasticsearch-plugin install --batch ingest-attachment