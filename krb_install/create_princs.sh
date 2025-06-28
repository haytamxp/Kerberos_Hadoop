#!/bin/bash

source .env

nodes=("hdfs-nn.mergrweb.me" "hdfs-dn1.mergrweb.me" "hdfs-dn2.mergrweb.me")
users=("host" "hadoopadmin" "HTTP" "hive" "hdfs" "yarn" "mapred")

for node in "${nodes[@]}"; do
        for user in "${users[@]}"; do
                kadmin.local -q "addprinc -pw $pwd $user/$node@KRB.MERGRWEB.ME"
        done
done
