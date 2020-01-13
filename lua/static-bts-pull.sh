#!/usr/bin/env bash

staticBtsDir="/usr/local/openresty/nginx/html/www/static-bts"

if [ -d $staticBtsDir ]; then
    cd $staticBtsDir && git pull
    echo 'done'
else
    echo 'dir not found'
fi
