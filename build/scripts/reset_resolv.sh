#!/bin/bash

echo "# MANAGED BY reset_resolv.sh" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# ALLOW/FIX DOCKER PORT ACCESS TO THIS CONTAINER ON eth0
SOURCENET=$allow_subnet
INTERFACE=eth0
if [[ "$SOURCENET" != "" ]]; then
	GATEWAY=$(ip route | grep default | grep $INTERFACE | awk '{print $3}')
	echo "Allowing $SOURCENET to access this container on $INTERFACE"
	ip route replace $SOURCENET via $GATEWAY dev $INTERFACE
fi
