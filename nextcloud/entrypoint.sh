#!/bin/sh

#
# Update the data dir perms
#
data_dir="/data"
sleep_time="10"

sleep $sleep_time

echo "Updating perms on $data_dir..."
docker exec -u root nextcloud chown -R :www-data $data_dir
docker exec -u root nextcloud chmod -R g+rwx $data_dir
docker exec -u root nextcloud chmod -R 0770 $data_dir
echo "Perm update complete."

#
# Cron job to scan files
#
# docker exec -u www-data nextcloud-app php occ files:scan --all

#
# Cron job to generate previews
#
# docker exec -i nextcloud sudo -u abc php7 /config/www/nextcloud/occ preview:pre-generate

#
# Cron job to index with elastic search
#
# sudo -u apache php /var/www/html/nextcloud/occ fulltextsearch:index

# Start a long-running process / daemon
tail -f /dev/null