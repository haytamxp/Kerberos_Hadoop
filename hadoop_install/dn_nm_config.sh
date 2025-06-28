#!/bin/bash
# AUTHOR : GRAOUI ABDERRAHMANE
# CONFIGURED FOR OCI STANDARD AMD E2.1 MICRO VPS (1c/2t x86 vCPU at 2Ghz + 1GB of RAM + 4GB of swap)


# Source from .env file
source .env

WORKINGDIR="$HADOOPUSRHOME/$INSTALLDIR/hadoop/etc/hadoop"

echo "Configuring..."

$DN = $DN_CONFIGS/$1/*
cp -f $DN $WORKINGDIR

echo -e "DataNode+NodeManager configuration is done! Make sure you have a working Kerberos and OpenLDAP server\nIn case of issues please verify the configuration as explained in the Hadoop docs : https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html#Configuring_the_Hadoop_Daemons "
