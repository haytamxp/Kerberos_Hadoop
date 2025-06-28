#!/bin/bash
# AUTHOR: GRAOUI ABDERRAHMANE
# CONFIGURED FOR A LOCAL HOMELAB UBUNTU SERVER RUNNING (2c/4t x86 vCPU at 2.00Ghz, 4GB of RAM + 4GB swap)


# Source from .env file
source .env

#Move binary to /usr/bin/
cp bin/hdp /usr/bin

WORKINGDIR="$HADOOPUSRHOME/$INSTALLDIR/hadoop/etc/hadoop"

echo "Configuring NameNode..."

$NN = $NN_CONFIGS/*
cp -f $NN $WORKINGDIR

chown -R hadoopadmin:hadoopadmin $WORKINGDIR

cat << EOF >> /etc/hosts

#SINCE KERBEROS IS ON LAN, REPLACE WITH FQDN OTHERWISE
10.101.100.92 krb.mergrweb.me

127.0.0.1 namenode
https://hdfs-dn1.mergrweb.me dn1
https://hdfs-dn2.mergrweb.me dn2

EOF

echo -e "NameNode+ResourceManager configuration is done! Make sure you have a working Kerberos and OpenLDAP server\nIn case of issues please verify the configuration as explained in the Hadoop docs : https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html#Configuring_the_Hadoop_Daemons  "
