#!/bin/sh
echo "Starting ssh tunnel..."
ssh -g -F /home/hadoopadmin/.ssh/config -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -N \
  -L 0.0.0.0:6200:localhost:88 \
  -L 0.0.0.0:389:localhost:389 \
  krb
echo "SSH tunnel stopped or failed"
#sleep 3600  # keep container alive to debug
