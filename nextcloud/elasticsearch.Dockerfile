FROM $REPO:$VERSION

RUN bin/elasticsearch-plugin install --batch ingest-attachment