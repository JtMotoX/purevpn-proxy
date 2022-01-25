#!/bin/bash

while true; do
	# CHECK TRANSMISSION DOWNLOADS CONNECTIVITY
	touch /var/lib/transmission-daemon/downloads/.check-connection >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "Looks like we lost connectivity to transmission downloads directory"
		echo "Exiting . . ."
		exit 1
	fi
	rm -f /var/lib/transmission-daemon/downloads/.check-connection

	# CHECK VPN CONNECTIVITY
	purevpn --status | grep 'Connected' >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "Looks like VPN connectivity was lost"
		echo "Exiting . . ."
		exit 1
	fi

	# CHECK INTERNET CONNECTIVITY
	wget -q --spider --timeout=60 http://google.com >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "Looks like we lost internet connectivity"
		echo "Exiting . . ."
		exit 1
	fi

	sleep 10
done
