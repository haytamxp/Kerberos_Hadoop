#!/bin/sh
echo "Starting ssh tunnel..."
ssh -g -F /home/hadoopadmin/.ssh/config -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -N \
  -L 0.0.0.0:50072:localhost:50072 \
  -L 0.0.0.0:9884:localhost:9884 \
  -L 0.0.0.0:9885:localhost:9885 \
  -L 0.0.0.0:9886:localhost:9886 \
  -L 0.0.0.0:9887:localhost:9887 \
  -L 0.0.0.0:8062:localhost:8042 \
  -L 0.0.0.0:8064:localhost:8044 \
  dn2
echo "SSH tunnel stopped or failed"
#sleep 3600  # keep container alive to debug
