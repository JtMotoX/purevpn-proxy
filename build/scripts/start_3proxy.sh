#!/bin/bash

set -e

# GET INTERNAL AND EXTERNAL IP
INTERNAL_IP=$(ifconfig eth0 | grep '\sinet\s' | awk '{print $2}')
echo "INTERNAL_IP: ${INTERNAL_IP}"
EXTERNAL_IP=$(ifconfig tun0 | grep '\sinet\s' | awk '{print $2}')
echo "EXTERNAL_IP: ${EXTERNAL_IP}"

# UPDATE INTERNAL AND EXTERNAL IP IN CONFIGS
sed -i "s/-i1\.1\.1\.1/-i${INTERNAL_IP}/g" "${proxy_dir}/conf/3proxy.cfg"
sed -i "s/-e1\.1\.1\.1/-e${EXTERNAL_IP}/g" "${proxy_dir}/conf/3proxy.cfg"

grep '^socks' "${proxy_dir}/conf/3proxy.cfg"

# START THE SERVICE
sudo /usr/sbin/service 3proxy start
sleep 1
