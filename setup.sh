#!/bin/bash

cd "$(dirname "$0")"

chmod 755 ./build/scripts/*.sh

mkdir -p ./transmission/{downloads,resume,torrents}
chown -R 101:101 ./transmission/{downloads,resume,torrents}
chmod -R 775 ./transmission/{downloads,resume,torrents}
