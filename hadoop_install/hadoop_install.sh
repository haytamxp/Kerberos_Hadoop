#!/bin/bash
# AUTHOR : GRAOUI ABDERRAHMANE
# User named hadoopadmin created via the hadoopusr_setup.sh is expected to exist beforehand

# Source variables from .env file
source .env

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install dependencies
if ! dpkg -l wget coreutils openjdk-8-jre ssh pdsh sed >/dev/null 2>&1 ; then
  echo "Installing dependencies..."
	apt update
	apt install wget coreutils openjdk-8-jre ssh pdsh sed -y || echo "Installation failed" && exit -1
fi
# Setup installation directories
echo "Setting up installations directories..."
mkdir -p $HADOOPUSRHOME/$INSTALLDIR
cd $HADOOPUSRHOME/$INSTALLDIR

# Downloads Hadoop
echo "Getting Apache Hadoop 3.4.1..."
if [ ! -f "./hadoop-3.4.1.tar.gz" ]; then
  wget "$HADOOPLINK"
  if [ $? -ne 0 ]; then
    echo "Download failed!"
    exit 1
  fi
fi

if [ -f "./hadoop-3.4.1.tar.gz" ]; then
  if [ ! -f "./hadoop-3.4.1.tar.gz.sha512" ]; then
    wget "$SHA512LINK"
    if [ $? -ne 0 ]; then
      echo "Download failed!"
      exit 1 
    fi
  fi
fi

echo "Checksum validation..."
if sha512sum -c ./"$SHA512" ; then
	echo 'Hash is valid'
else
	echo 'Hash is invalid'
	exit -1
fi

# Extract Hadoop
echo "Extracting Hadoop..."
if [ ! -d "./hadoop*" ]; then
	tar -xvf "$HADOOPTAR"
fi



cd "hadoop-3.4.1"

echo "Setting up safe process and log directories..."
mkdir -p runtime/proc runtime/log
find runtime -type d -exec chmod 660 {} \;
chmod 660 runtime


# Add dir to PATH

echo "Adding directory to PATH..."
cat >> $HADOOPUSRHOME/.bashrc << EOL
if ! [[ "$PATH" =~ "$HADOOPUSRHOME/$INSTALLDIR/hadoop/bin:" ]]; then
    PATH="$HADOOPUSRHOME/$INSTALLDIR/hadoop/bin:$PATH"
fi
export PATH
export HADOOP_HOME=/home/hadoopadmin/hadoopinstall/hadoop
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_PID_DIR=${HADOOP_HOME}/runtime/proc
export HADOOP_LOG_DIR=${HADOOP_HOME}/runtime/log
export HADOOP_SBIN=${HADOOP_HOME}/sbin
EOL

# Setting up systemd service for the SSH Tunnel to Kerberos

cp ./conf/krb-ssh-tunnel.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now krb-ssh-tunnel.service

echo "Cleaning up..."
chown hadoopadmin:hadoopadmin -R "$HADOOPUSRHOME/$INSTALLDIR/hadoop-3.4.1"
rm $HADOOPUSRHOME/$INSTALLDIR/$HADOOPTAR
rm $HADOOPUSRHOME/$INSTALLDIR/$SHA512
mv "hadoop-3.4.1" "hadoop"

echo "Installation has finished successfully!"
exit 0
