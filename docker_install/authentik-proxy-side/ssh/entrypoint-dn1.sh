#!/bin/sh
echo "Starting ssh tunnel..."
ssh -g -F /home/hadoopadmin/.ssh/config -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -N \
 -L 0.0.0.0:50070:localhost:50070 \
 -L 0.0.0.0:9864:localhost:9864 \
 -L 0.0.0.0:9865:localhost:9865 \
 -L 0.0.0.0:9866:localhost:9866 \
 -L 0.0.0.0:9867:localhost:9867 \
 -L 0.0.0.0:8043:localhost:8042 \
 -L 0.0.0.0:8045:localhost:8044 \
 dn1
echo "SSH tunnel stopped or failed"
#sleep 3600  # keep container alive to debug
