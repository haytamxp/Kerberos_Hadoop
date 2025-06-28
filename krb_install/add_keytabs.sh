#!/bin/bash

source .env

nodes=("hdfs-nn.mergrweb.me" "hdfs-dn1.mergrweb.me" "hdfs-dn2.mergrweb.me")
users=("host" "hdfs" "yarn" "HTTP" "hive" "mapred" "hadoopadmin")

for node in "${nodes[@]}"; do
        for user in "${users[@]}"; do
                kadmin.local -q "ktadd -k /etc/krb5.keytab $user/$node@KRB.MERGRWEB.ME"
        done
done
