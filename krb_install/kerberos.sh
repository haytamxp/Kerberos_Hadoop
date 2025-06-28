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

cp conf/krb/krb5.conf /etc/
cp conf/krb/krb5.keytab /etc/
cp conf/krb/krb5kdc/ /etc/krb5kdc
chmod 644 krb5.conf
chmod 600 krb5.keytab
chown root:root krb5.conf krb5.keytab -R /etc/krb5kdc
