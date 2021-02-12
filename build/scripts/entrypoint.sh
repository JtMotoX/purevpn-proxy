#!/bin/bash

# Workaround for GitLab ENTRYPOINT double execution (issue: 1380)
[ -f /tmp/gitlab-runner.lock ] && exit || >/tmp/gitlab-runner.lock

logTailArr=()

for f in /entrypoint.d/*.sh; do
	echo "Executing $f . . ."
	. "$f" -H || break
done

echo "Container is up and running"

tail -n+1 -f ${logTailArr[@]}
