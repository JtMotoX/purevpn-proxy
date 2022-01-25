#!/bin/bash

set -e

logTailArr=()

# FUNCTION TO CHECK IF ARGUMENT IS TRUE
bool() {
	string=$1
	if [[ "${string,,}" == "true" || "$string" == "1" ]]; then
		return 0
	fi
	return 1
}

. /etc/profile

# VPN
echo "Starting vpn service . . ."
sudo --preserve-env /scripts/start_vpn.sh
logTailArr+=("/var/log/purevpn.log")

# KILLSWITCH
if "$killswitch" != "false"; then
	echo 'y' | sudo --preserve-env /scripts/killswitch_enable.sh
else
	echo "Killswitch is NOT enabled"
fi

# PROXY
if [[ "${proxy_service}" == "3proxy" ]]; then
	echo "Starting 3proxy proxy service . . ."
	sudo --preserve-env /scripts/start_3proxy.sh
	logTailArr+=("${proxy_dir}/logs/*.log")
elif [[ "${proxy_service}" == "dante" ]]; then
	echo "Starting dante proxy service . . ."
	sudo --preserve-env /scripts/start_dante.sh
	logTailArr+=("/var/log/sockd.log")
else
	echo "Not starting proxy service since none was defined"
fi

# TRANSMISSION
echo "Starting transmission . . ."
sudo --preserve-env /scripts/start_transmission.sh
logTailArr+=("/var/log/transmission.log")

echo "Container is up and running"

# STREAM LOG FILES TO CONTAINER OUTPUT
tail -n+1 -f ${logTailArr[@]} &

# START MONITORING CONNECTIVITY AND PROCESSES
/scripts/monitor.sh
