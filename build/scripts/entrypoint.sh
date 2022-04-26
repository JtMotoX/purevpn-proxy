#!/bin/bash

set -e

# CONVERT 1PASSWORD ENVIRONMENT VARIABLES
if env | grep -E '^[^=]*=OP:' >/dev/null; then
	curl -s -o /tmp/1password-vars.sh "https://raw.githubusercontent.com/JtMotoX/1password-docker/main/1password/op-vars.sh"
	chmod 755 /tmp/1password-vars.sh
	. /tmp/1password-vars.sh
	rm -f /tmp/1password-vars.sh
fi

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

# CHECK TRANSMISSION DOWNLOADS CONNECTIVITY
if ! /scripts/check_downloads_connection.sh; then exit 1; fi

# CHECK INTERNET CONNECTIVITY
if ! /scripts/check_internet_connection.sh; then exit 1; fi

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
