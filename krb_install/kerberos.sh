#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install dependencies
if ! dpkg -l krb5-kdc krb5-admin-server krb5-kdc-ldap >/dev/null 2>&1 ; then
  echo "Installing dependencies..."
	apt update
	apt install krb5-kdc krb5-admin-server krb5-kdc-ldap -y || echo "Installation failed" && exit -1
fi

lan_ip=${hostname -I | cut -d ' ' -f 1}

cat << EOF >> /etc/hosts
# Kerberos domains
$lan_ip krb.mergrweb.me
EOF

krb5_newrealm

bash create_princs.sh

bash add_keytabs.sh

KRB_DEFAULT_REALM = ${cat /etc/krb5.conf | grep default_realm | tr -s ' ' | cut -d ' ' -f 4}
echo "=============================================================="
echo " /!\ ADDING FULL PRIVILEGES TO */ADMIN@$KRB_DEFAULT_REALM"
echo "=============================================================="
echo "*/admin@$KRB_DEFAULT_REALM  *" >> /etc/krb5kdc/kadm5.acl


echo "$KRB_DEFAULT_REALM" > .currentkrbdefaultrealm


