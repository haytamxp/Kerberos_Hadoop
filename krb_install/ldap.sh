#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install dependencies
if ! dpkg -l slapd ldap-utils gunzip schema2ldif >/dev/null 2>&1 ; then
  echo "Installing dependencies..."
	apt update
	apt install slapd ldap-utils gunzip schema2ldif -y || echo "Installation failed" && exit -1
fi

mkdir -p /etc/ldap/
cp conf/ldap/ldap.conf /etc/ldap/ldap.conf
chmod 644 /etc/ldap/ldap.conf
chown root:root /etc/ldap/ldap.conf

cp /usr/share/doc/krb5-kdc-ldap/kerberos.schema.gz /etc/ldap/schema/
gunzip /etc/ldap/schema/kerberos.schema.gz

ldap-schema-manager -i kerberos.schema

ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
add: olcDbIndex
olcDbIndex: krbPrincipalName eq,pres,sub
EOF

ldapadd -x -D cn=admin,dc=krb,dc=mergrweb,dc=me -W <<EOF
dn: uid=kdc-service,dc=krb,dc=mergrweb,dc=me
uid: kdc-service
objectClass: account
objectClass: simpleSecurityObject
userPassword: {CRYPT}x
description: Account used for the Kerberos KDC

dn: uid=kadmin-service,dc=krb,dc=mergrweb,dc=me
uid: kadmin-service
objectClass: account
objectClass: simpleSecurityObject
userPassword: {CRYPT}x
description: Account used for the Kerberos Admin server
EOF

ldappasswd -x -D cn=admin,dc=krb,dc=mergrweb,dc=me -W -S uid=kdc-service,dc=krb,dc=mergrweb,dc=me
ldappasswd -x -D cn=admin,dc=krb,dc=mergrweb,dc=me -W -S uid=kadmin-service,dc=krb,dc=mergrweb,dc=me

ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
add: olcAccess
olcAccess: {2}to attrs=krbPrincipalKey
  by anonymous auth
  by dn.exact="uid=kdc-service,dc=krb,dc=mergrweb,dc=me" read
  by dn.exact="uid=kadmin-service,dc=krb,dc=mergrweb,dc=me" write
  by self write
  by * none
-
add: olcAccess
olcAccess: {3}to dn.subtree="cn=krbContainer,dc=krb,dc=mergrweb,dc=me"
  by dn.exact="uid=kdc-service,dc=krb,dc=mergrweb,dc=me" read
  by dn.exact="uid=kadmin-service,dc=krb,dc=mergrweb,dc=me" write
  by * none
EOF

kdb5_ldap_util -D cn=admin,dc=krb,dc=mergrweb,dc=me create -subtrees dc=krb,dc=mergrweb,dc=me -r KRB.MERGRWEB.ME -s -H ldapi:///
kdb5_ldap_util -D cn=admin,dc=krb,dc=mergrweb,dc=me stashsrvpw -f /etc/krb5kdc/service.keyfile uid=kdc-service,dc=krb,dc=mergrweb,dc=me
kdb5_ldap_util -D cn=admin,dc=krb,dc=mergrweb,dc=me stashsrvpw -f /etc/krb5kdc/service.keyfile uid=kadmin-service,dc=krb,dc=mergrweb,dc=me

