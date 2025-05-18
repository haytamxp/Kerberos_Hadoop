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
if [ ! -d "./hadoop-3.4.1" ]; then
	tar -xvf "$HADOOPTAR"
fi

cd "hadoop-3.4.1"

echo "Setting up safe process and log directories..."
mkdir -p runtime/proc runtime/log
find runtime -type d -exec chmod 600 {} \;
chmod 600 runtime


# Add dir to PATH

echo "Adding directory to PATH..."
cat >> $HADOOPUSRHOME/.bashrc << EOL
if ! [[ "$PATH" =~ "$HADOOPUSRHOME/$INSTALLDIR/hadoop-3.4.1/bin:" ]]; then
    PATH="$HADOOPUSRHOME/$INSTALLDIR/hadoop-3.4.1/bin:$PATH"
fi
export PATH
EOL

echo "Adding JAVA_HOME to hadoop-env.sh..."
echo 'export JAVA_HOME=/usr/java/latest' >> "$HADOOPUSRHOME/$INSTALLDIR/hadoop-3.4.1/etc/hadoop/hadoop-env.sh"

echo "Cleaning up..."
chown hadoopadmin:hadoopadmin -R "$HADOOPUSRHOME/$INSTALLDIR/hadoop-3.4.1"
rm -f "$HADOOPUSRHOME/$INSTALLDIR/hadoop-3.4.1.tar.*"

echo "Installation has finished successfully!"
exit 0
