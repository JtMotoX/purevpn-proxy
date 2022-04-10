#!/bin/sh

while true; do
	# CHECK TRANSMISSION DOWNLOADS CONNECTIVITY
	if ! /scripts/check_downloads_connection.sh; then exit 1; fi

	# CHECK VPN CONNECTIVITY
	purevpn --status | grep 'Connected' >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Looks like VPN connectivity was lost"
		echo "Exiting . . ."
		exit 1
	fi

	# CHECK INTERNET CONNECTIVITY
	if ! /scripts/check_internet_connection.sh; then exit 1; fi

	sleep 10
done
