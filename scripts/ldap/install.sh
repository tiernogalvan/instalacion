#!/bin/bash
# Instala SSSD para tener login al servidor LDAP

apt-get install -y sssd-ldap ldap-utils
install -o root -g root -m 0400 sssd.conf /etc/sssd/

