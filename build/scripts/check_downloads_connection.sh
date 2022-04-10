#!/bin/sh

# CHECK TRANSMISSION DOWNLOADS CONNECTIVITY
CONNECTION_FILE="/var/lib/transmission-daemon/downloads/.check-connection"
touch "${CONNECTION_FILE}" >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Looks like we lost connectivity to transmission downloads directory"
	echo "Exiting . . ."
	exit 1
fi
rm -f "${CONNECTION_FILE}"
