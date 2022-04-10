#!/bin/sh

# CHECK INTERNET CONNECTIVITY
wget -q --spider --timeout=60 http://google.com >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Looks like we lost internet connectivity"
	echo "Exiting . . ."
	exit 1
fi
