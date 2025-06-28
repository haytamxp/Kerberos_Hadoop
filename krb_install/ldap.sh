#!/bin/bash

# Change to suit your environment

BASEDN='dc=krb,dc=mergrweb,dc=me'
KRBREALM='KRB.MERGRWEB.ME' # CASE SENSITIVE, KEEP UPPERCASE

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
if [[ -f "/etc/ldap/ldap.conf "]]; then
  mv /etc/ldap/ldap.conf /etc/ldap/ldap.conf.old
fi

cat << EOF >> /etc/ldap/ldap.conf
BASE    $BASEDN
URI     ldap://localhost:389
EOF

# INTEGRATING OPENLDAP AS BACKEND FOR KERBEROS 5

# KRB realm assumed to be $KRBREALM [UPPERCASE]
# in OpenLDAP that corresponds to $BASEDN
KRB_DEFAULT_REALM = ${cat .currentkrbdefaultrealm}
if [[ "$KRB_DEFAULT_REALM" != "$KRBREALM" ]]; then
    echo "/!\/!\/!\/!\   WARNING! CURRENT DEFAULT REALM IS : $KRB_DEFAULT_REALM /!\/!\/!\/!\ "
    echo "WHICH IS NOT $KRBREALM, NOT INTEGRATING WITH OPENLDAP !"
    exit 2
fi
cp /usr/share/doc/krb5-kdc-ldap/kerberos.schema.gz /etc/ldap/schema/
gunzip /etc/ldap/schema/kerberos.schema.gz

ldap-schema-manager -i kerberos.schema

ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
add: olcDbIndex
olcDbIndex: krbPrincipalName eq,pres,sub
EOF

ldapadd -x -D cn=admin,$BASEDN -W <<EOF
dn: uid=kdc-service,$BASEDN
uid: kdc-service
objectClass: account
objectClass: simpleSecurityObject
userPassword: {CRYPT}x
description: Account used for the Kerberos KDC

dn: uid=kadmin-service,$BASEDN
uid: kadmin-service
objectClass: account
objectClass: simpleSecurityObject
userPassword: {CRYPT}x
description: Account used for the Kerberos Admin server
EOF

ldappasswd -x -D cn=admin,$BASEDN -W -S uid=kdc-service,$BASEDN
ldappasswd -x -D cn=admin,$BASEDN -W -S uid=kadmin-service,$BASEDN

ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
add: olcAccess
olcAccess: {2}to attrs=krbPrincipalKey
  by anonymous auth
  by dn.exact="uid=kdc-service,$BASEDN" read
  by dn.exact="uid=kadmin-service,$BASEDN" write
  by self write
  by * none
-
add: olcAccess
olcAccess: {3}to dn.subtree="cn=krbContainer,$BASEDN"
  by dn.exact="uid=kdc-service,$BASEDN" read
  by dn.exact="uid=kadmin-service,$BASEDN" write
  by * none
EOF

kdb5_ldap_util -D cn=admin,$BASEDN create -subtrees $BASEDN -r $KRBREALM -s -H ldapi:///
kdb5_ldap_util -D cn=admin,$BASEDN stashsrvpw -f /etc/krb5kdc/service.keyfile uid=kdc-service,$BASEDN
kdb5_ldap_util -D cn=admin,$BASEDN stashsrvpw -f /etc/krb5kdc/service.keyfile uid=kadmin-service,$BASEDN

cat << EOF >> /etc/krb5.conf
[dbdefaults]
        ldap_kerberos_container_dn = cn=krbContainer,$BASEDN

[dbmodules]
        openldap_ldapconf = {
                db_library = kldap
                ldap_kdc_dn = "uid=kdc-service,$BASEDN"
                ldap_kadmind_dn = "uid=kadmin-service,$BASEDN"
                ldap_service_password_file = /etc/krb5kdc/service.keyfile
                ldap_servers = ldapi:///
                ldap_conns_per_server = 5
        }
EOF
