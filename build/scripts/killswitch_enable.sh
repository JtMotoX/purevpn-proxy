#!/bin/bash

echo "Enabling Killswitch"

sudo service ufw start
sudo ufw reset
sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw allow out on tun0 from any to any

# ALLOW INCOMING TRANSMISSION WEB CLIENT
sudo ufw allow 9091

# ALLOW INCOMING SOCKS PROXY
sudo ufw allow 1080

sudo ufw enable
