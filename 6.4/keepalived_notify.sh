#!/bin/bash

#Write status to temporaray file.
touch /var/run/keepalived_status
chmod 0644 /var/run/keepalived_status
echo "$1 $2 has transitioned to the $3 state with a priority of $4" > /var/run/keepalived_status