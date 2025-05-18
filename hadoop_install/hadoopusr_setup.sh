#!/bin/bash
# AUTHOR : GRAOUI ABDERRAHMANE

# Check if hadoopadmin user already exists

if id hadoopadmin >/dev/null 2>&1; then
  echo "hadoopadmin already exists, aborting..."
  exit
fi

# Only run this script if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# 0. Source sshpubkey

# Make sure file named .secretenv exists in current directory
if [ ! -f ./.secretenv ]; then
    echo ".secretenv file not found! Aborting..."
    exit
fi

source .secretenv

# 1. Create the user
adduser --disabled-password --gecos "" hadoopadmin

# 2. Set SSH public key (adjust path or use echo as needed)
mkdir -p /home/hadoopadmin/.ssh
echo $SSH_PUB_KEY > /home/hadoopadmin/.ssh/authorized_keys
chmod 700 /home/hadoopadmin/.ssh
chmod 600 /home/hadoopadmin/.ssh/authorized_keys
chown -R hadoopadmin:hadoopadmin /home/hadoopadmin

# 3. Lock down all other home directories
for dir in /home/*; do
    user=$(basename "$dir")
    if [ "$user" != "hadoopadmin" ]; then
        chmod 700 "$dir"
    fi
done

# 4. Deny sudo and docker access
deluser hadoopadmin sudo 2>/dev/null || true
deluser hadoopadmin docker 2>/dev/null || true

# 5. Prepare Hadoop config directory
mkdir -p /opt/hadoop
chown -R hadoopadmin:hadoopadmin /opt/hadoop
chmod -R 750 /opt/hadoop

# 6. Prepare custom Kerberos config
mkdir -p /opt/hadoop-conf
cp /etc/krb5.conf /opt/hadoop-conf/krb5.conf
chown -R hadoopadmin:hadoopadmin /opt/hadoop-conf
chmod -R 750 /opt/hadoop-conf

# Optional: append include to system krb5.conf (do only once)
if ! grep -q '/opt/hadoop-conf' /etc/krb5.conf; then
    echo -e "\n# Include Hadoop Kerberos config\nincludedir /opt/hadoop-conf/" >> /etc/krb5.conf
fi

# 7. Restrict docker.sock (make sure not group-accessible to this user)
chmod 660 /var/run/docker.sock
chown root:docker /var/run/docker.sock

# 8. Deny all sudo use explicitly
echo "hadoopadmin ALL=(ALL:ALL) !ALL" > /etc/sudoers.d/99-hadoopadmin-nosudo
chmod 440 /etc/sudoers.d/99-hadoopadmin-nosudo

echo "✅ hadoopadmin is ready to SSH in and install Hadoop in /opt/hadoop"
echo "They can also manage /opt/hadoop-conf/krb5.conf, included in the system config."
