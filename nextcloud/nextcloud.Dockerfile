FROM nextcloud:25.0.2

ENTRYPOINT chown -R :www-data /data && chmod -R g+rwx /data && chmod -R 0770 /data && /bin/bash