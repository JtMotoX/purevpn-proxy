#!/bin/bash

set -e

# Workaround for GitLab ENTRYPOINT double execution (issue: 1380)
[ -f /tmp/gitlab-runner.lock ] && exit || >/tmp/gitlab-runner.lock

logTailArr=()

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

	echo "Starting dante proxy service . . ."
	sudo --preserve-env /scripts/start_dante.sh
	logTailArr+=("/var/log/sockd.log")
echo "Container is up and running"

tail -n+1 -f ${logTailArr[@]}
