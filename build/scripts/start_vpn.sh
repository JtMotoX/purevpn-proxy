#!/bin/bash

set -e

# verify PureVPN installed
if ! which purevpn > /dev/null; then
    echo "ERROR: purevpn package is missing"
    exit 2
fi

purevpn --version

ORIG_IP=$(curl -s --connect-timeout 5 --max-time 10 'ifconfig.me')
echo "Current IP: ${ORIG_IP}"

# stop purevpn service
pkill -f -9 purevpnd || true

# fix resolve
echo "Fixing /etc/resolv.conf . . ."
sleep 5
/scripts/reset_resolv.sh

# start purevpn service
/usr/sbin/service purevpn start

purevpn --logout >/dev/null

# login to purevpn
expect <<EOD
spawn purevpn --login
expect "Username:"
send "${purevpn_username}\r"
expect "Password:"
send "${purevpn_password}\r"
expect #
EOD

if [ -n "$purevpn_location" ]; then
	LOCATION="$purevpn_location"
else
	# get all location codes
	LOCATIONS=$(purevpn --location)
	echo -e "$LOCATIONS"
	LOCATION_CODES=$(echo -e $LOCATIONS | grep -o -E '[A-Z]{2}')
	if [ -n "$purevpn_location_exclude" ]; then
		for location_exclude in ${purevpn_location_exclude//,/ }; do
			LOCATION_CODES=$(echo "${LOCATION_CODES}" | grep -v "${location_exclude}")
		done
	fi
	ARRAY=(${LOCATION_CODES//:/ })
	LEN=${#ARRAY[@]}

	# select random one
	echo "Picking random location . . ."
	LOCATION=${ARRAY[$((RANDOM % $LEN))]}
fi

# connect
echo "Connecting to ${LOCATION} . . ."
purevpn --connect "${LOCATION}"

# fix resolve
echo "Fixing /etc/resolv.conf . . ."
sleep 5
/scripts/reset_resolv.sh

NEW_IP=$(curl -s 'icanhazip.com')
echo "Original IP: ${ORIG_IP}"
echo "New IP (${LOCATION}): ${NEW_IP}"
echo

if [[ "${NEW_IP}" == "${ORIG_IP}" ]]; then
	echo "IP did not change so connection must not have been successful"
	exit 1
fi
