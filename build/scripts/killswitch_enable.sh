#!/bin/bash

echo "Enabling Killswitch"

sudo service ufw start
sudo ufw reset
sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw allow out on tun0 from any to any

SOCKS_PORT=$(grep '^internal:' /etc/danted.conf | sed -E 's/.*=\s*([0-9]*).*/\1/g')
if [[ "$SOCKS_PORT" != "" ]]; then
	echo "Allow port $SOCKS_PORT"
	sudo ufw allow $SOCKS_PORT
fi

sudo ufw enable
