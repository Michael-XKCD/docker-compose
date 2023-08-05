#!/bin/sh

data_dir="/data"
script="change-perms.sh"

echo "Executing $script on $data_dir..."
chown -R :www-data $data_dir
chmod -R g+rwx $data_dir
chmod -R 0770 $data_dir
echo "$script completed."