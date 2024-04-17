#!/bin/bash
# Instala SSSD para tener login al servidor LDAP

apt-get install -y sssd-ldap ldap-utils
install -o root -g root -m 0600 -D sssd.conf /etc/sssd/
systemctl restart sssd.service
pam-auth-update --enable mkhomedir

