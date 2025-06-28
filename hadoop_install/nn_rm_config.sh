#!/bin/bash
# AUTHOR: GRAOUI ABDERRAHMANE
# CONFIGURED FOR A LOCAL HOMELAB UBUNTU SERVER RUNNING (2c/4t x86 vCPU at 2.00Ghz, 4GB of RAM + 4GB swap)


# Source from .env file
source .env

WORKINGDIR="$HADOOPUSRHOME/$INSTALLDIR/hadoop/etc/hadoop"

echo "Configuring NameNode..."

$NN = $NN_CONFIGS/*
cp -f $NN $WORKINGDIR

echo -e "NameNode+ResourceManager configuration is done! Make sure you have a working Kerberos and OpenLDAP server\nIn case of issues please verify the configuration as explained in the Hadoop docs : https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html#Configuring_the_Hadoop_Daemons  "
