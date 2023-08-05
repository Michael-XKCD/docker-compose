#!/bin/sh

sleep_time="10"

/bin/sh "/entrypoint.sh"

sleep $sleep_time

/bin/sh "/change_perms.sh"