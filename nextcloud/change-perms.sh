#!/bin/sh

data_dir="/data"
sleep_time="10"
script="change-perms.sh"

echo "Waiting $sleep_time secs for $data_dir to mount..."
sleep $sleep_time
echo "$sleep_time secs is over."

echo "Executing $script on $data_dir..."
chown -R :www-data $data_dir
chmod -R g+rwx $data_dir
chmod -R 0770 $data_dir
echo "$script completed."