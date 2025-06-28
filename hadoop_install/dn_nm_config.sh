#!/bin/bash
# AUTHOR : GRAOUI ABDERRAHMANE
# CONFIGURED FOR OCI STANDARD AMD E2.1 MICRO VPS (1c/2t x86 vCPU at 2Ghz + 1GB of RAM + 4GB of swap)


# Source from .env file
source .env

WORKINGDIR="$HADOOPUSRHOME/$INSTALLDIR/hadoop/etc/hadoop"

echo "Configuring..."

$DN = $DN_CONFIGS/$1/*
cp -f $DN $WORKINGDIR

chown -R hadoopadmin:hadoopadmin $WORKINGDIR

cat << EOF >> /etc/hosts
#SET KERBEROS URL TO LOCALHOST SINCE WE LINK TO THE KDC SERVER VIA SSH TUNNELLING
127.0.0.1 krb.mergrweb.me
EOF

echo -e "DataNode+NodeManager configuration is done! Make sure you have a working Kerberos and OpenLDAP server\nIn case of issues please verify the configuration as explained in the Hadoop docs : https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html#Configuring_the_Hadoop_Daemons "
