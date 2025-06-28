#!/bin/bash

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

mkdir -p /home/ubuntu/composers/webauth
chown 1000:1000 -R /home/ubuntu/composers

if [[ "$1" == "krb" ]]; then
    cp -r authentik-krb-side/* /home/ubuntu/composers/webauth/
    chown 1000:1000 -R /home/ubuntu/composers/webauth
elif [[ "$1" == "proxy" ]]; then
    cp -r authentik-proxy-side/* /home/ubuntu/composers/webauth/
    chown 1000:1000 -R /home/ubuntu/composers/webauth
else
    echo 'option not specified, exiting....'
    exit 1
fi

cd /home/ubuntu/composers/webauth

docker compose up -d

docker ps

echo "docker compose started, please check for errors if it occurs"
