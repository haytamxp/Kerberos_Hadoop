#!/bin/bash
# AUTHOR : GRAOUI ABDERRAHMANE
# User named hadoopadmin created via the hadoopusr_script.sh is expected to exist beforehand


# Source variables from .env file
source .env

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install dependencies
if [[ ! dpkg -l wget sha512sum openjdk-8-jre ssh pdsh >/dev/null 2>&1 ]] then;
	apt update
	apt install wget sha512sum openjdk-8-jre ssh pdsh -y || echo "Installation failed" && exit

# Setup installation directories
mkdir -p $HADOOPUSRHOME/$INSTALLDIR
cd $HADOOPUSRHOME/$INSTALLDIR
mkdir -p runtime/proc runtime/log
chown hadoopadmin:hadoopadmin -R runtime
find runtime -type d -exec chmod 600 {} \;
chmod 600 runtime

# Downloads Hadoop
wget $HADOOPLINK && wget $SHA512LINK
if sha512sum -c $SHA512 $HADOOPTAR; then
	echo 'Hash is valid'
else
	echo 'Hash is invalid'
	exit
fi

# Extract Hadoop
tar -xf $HADOOPTAR
cd $(awk -F ".tar" '{print $1}' $HADOOPTAR)

# Add dir to PATH
cat >> $HADOOPUSRHOME/.bashrc << EOL
if ! [[ "$PATH" =~ "$HADOOPUSRHOME/$INSTALLDIR/bin:" ]]; then
    PATH="$HADOOPUSRHOME/$INSTALLDIR/bin:$PATH"
fi
export PATH
EOL

echo 'export JAVA_HOME=/usr/java/latest' >> $HADOOPUSRHOME/$INSTALLDIR/etc/hadoop/hadoop-env.sh
