#!/bin/bash

set -e

danted -v
cat /etc/danted.conf >/dev/null
service danted restart
sleep 1
