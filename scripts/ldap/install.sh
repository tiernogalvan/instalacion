#!/bin/bash
#
# Instala SSSD para tener login al servidor LDAP
# Para vaciar la cache de SSSD:
#   $ sss_cache -E
#   $ sss_cache -u diurno
#

source ../functions.sh

apt-get install -y sssd-ldap ldap-utils libsss-sudo sssd-tools
install -o root -g root -m 0600 -t /etc/sssd/ -D sssd.conf
systemctl restart sssd.service

# Create user home dir (from /etc/skel) at login if not exists
pam-auth-update --enable mkhomedir
ensure_line_in_file /etc/pam.d/common-session pam_mkhomedir.so 'session optional			pam_mkhomedir.so umask=077'

# Instalar ldap.conf no es necesario pero configura herramientas de diagnostico
# como ldapsearch, ldapwhoami...
mkdir -p /etc/ldap
install -o root -g root -m 0644 -t /etc/ldap/ -D ldap.conf

# Creando estos ficheros apareceran estos usuarios disponibles en el login
# Deben existir también en LDAP para que se muestren.
touch /var/lib/AccountsService/users/diurno
touch /var/lib/AccountsService/users/vespertino
