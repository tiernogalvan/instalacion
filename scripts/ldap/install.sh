#!/bin/bash
#
# Instala SSSD para tener login al servidor LDAP
# Para vaciar la cache de SSSD:
#   $ sss_cache -E
#   $ sss_cache -u diurno
#

apt-get install -y sssd-ldap ldap-utils libsss-sudo sssd-tools
install -o root -g root -m 0600 -t /etc/sssd/ -D sssd.conf
systemctl restart sssd.service
pam-auth-update --enable mkhomedir

# Instalar ldap.conf no es necesario pero configura herramientas de diagnostico
# como ldapsearch, ldapwhoami...
mkdir -p /etc/ldap
install -o root -g root -m 0644 -t /etc/ldap/ -D ldap.conf

