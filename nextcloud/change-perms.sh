#!/bin/sh

data_dir="/data"
script="change-perms.sh"

echo "Waiting to $data_dir to mount..."
until [ ! -d $data_dir ]; do
    sleep 1
done
echo "$data_dir has mounted."

echo "Executing $script on $data_dir..."
chown -R :www-data $data_dir
chmod -R g+rwx $data_dir
chmod -R 0770 $data_dir
echo "$script completed."