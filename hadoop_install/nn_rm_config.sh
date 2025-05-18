#!/bin/bash
# AUTHOR: GRAOUI ABDERRAHMANE
# CONFIGURED FOR A LOCAL HOMELAB UBUNTU SERVER RUNNING (2c/4t x86 vCPU at 2.00Ghz, 4GB of RAM + 4GB swap)


# Source from .env file
source .env

WORKINGDIR=$HADOOPUSRHOME/$INSTALLDIR/etc/hadoop

cat << EOF >> "$WORKINGDIR/hadoop-env.sh"
export HDFS_NAMENODE_OPTS="-XX:+UseParallelGC -Xmx2g"
export HADOOP_PID_DIR=$HADOOPUSRHOME/$INSTALLDIR/runtime/proc
export HADOOP_LOG_DIR=$HADOOPUSRHOME/$INSTALLDIR/runtime/log
EOF

echo 'export YARN_RESOURCEMANAGER_OPTS="-Xmx512m"' >> "$WORKINGDIR/yarn-env.sh"

echo -e "NameNode+ResourceManager configuration is done!\nPlease manually configure the Hadoop daemons as explained in the Hadoop docs : https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html#Configuring_the_Hadoop_Daemons "
