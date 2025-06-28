#!/bin/sh
echo "Starting ssh tunnel..."
ssh -v -g -F /home/hadoopadmin/.ssh/config -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -N \
  -L 0.0.0.0:9005:localhost:9005 \
  -L 0.0.0.0:9870:localhost:9870 \
  -L 0.0.0.0:9871:localhost:9871 \
  -L 0.0.0.0:9868:localhost:9868 \
  -L 0.0.0.0:9869:localhost:9869 \
  -L 0.0.0.0:8032:localhost:8032 \
  -L 0.0.0.0:8030:localhost:8030 \
  -L 0.0.0.0:8088:localhost:8088 \
  -L 0.0.0.0:8090:localhost:8090 \
  -L 0.0.0.0:8031:localhost:8031 \
  -L 0.0.0.0:8033:localhost:8033 \
  -L 0.0.0.0:8444:localhost:8444 \
  -L 0.0.0.0:8440:localhost:8440 \
  -L 0.0.0.0:8441:localhost:8441 \
  namenode
echo "SSH tunnel stopped or failed"
sleep 3600  # keep container alive to debug
