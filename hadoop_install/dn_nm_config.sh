#!/bin/bash
# AUTHOR : GRAOUI ABDERRAHMANE
# CONFIGURED FOR OCI STANDARD AMD E2.1 MICRO VPS (1c/2t x86 vCPU at 2Ghz + 1GB of RAM + 4GB of swap)


# Source from .env file
source .env

WORKINGDIR="$HADOOPUSRHOME/$INSTALLDIR/hadoop-3.4.1/etc/hadoop"

echo "Configuring DataNode..."
cat << EOF >> "$WORKINGDIR/hadoop-env.sh"
export HDFS_DATANODE_OPTS="-XX:+UseParallelGC -Xmx512m"
export HADOOP_PID_DIR=$HADOOPUSRHOME/$INSTALLDIR/runtime/proc
export HADOOP_LOG_DIR=$HADOOPUSRHOME/$INSTALLDIR/runtime/log
EOF

echo "Configuring NodeManager..."
echo 'export YARN_NODEMANAGER_OPTS="-Xmx256m"' >> "$WORKINGDIR/yarn-env.sh"

echo -e "DataNode+NodeManager configuration is done!\nPlease manually configure the Hadoop daemons as explained in the Hadoop docs : https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html#Configuring_the_Hadoop_Daemons "
