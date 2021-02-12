#!/bin/bash
#
# Connect to random vpn endpoint
#
# Required environment variables:
#  - purevpn_username
#  - purevpn_password

set -e

# FUNCTION TO CHECK IF ARGUMENT IS TRUE
bool() {
	string=$1
	if [[ "${string,,}" == "true" || "$string" == "1" ]]; then
		return 0
	fi
	return 1
}

. /etc/profile

# verify PureVPN installed
if ! which purevpn > /dev/null; then
    echo "ERROR: purevpn package is missing"
    exit 2
fi

purevpn --version
danted -v

ORIG_IP=$(curl -s --connect-timeout 5 --max-time 10 'ifconfig.me')
echo "Current IP: ${ORIG_IP}"

# start purevpn service
sudo /usr/sbin/service purevpn restart

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
sudo --preserve-env /scripts/reset_resolv.sh

NEW_IP=$(curl -s 'icanhazip.com')
echo "Original IP: ${ORIG_IP}"
echo "New IP (${LOCATION}): ${NEW_IP}"
echo

if bool $killswitch; then
	echo 'y' | sudo /scripts/killswitch_enable.sh
fi

echo "Starting proxy service . . ."
sudo /usr/sbin/service danted restart

tail -n+1 -f \
	/var/log/purevpn.log \
	/var/log/sockd.log
