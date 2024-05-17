#!/bin/bash

die() { echo "$*" 1>&2 ; exit 1; }

if [[ "$EUID" -ne 0 ]]; then
  die "Please run as root."
fi

clear

systemctl stop sssd

sss_cache -E

# Grupo 999 para que coincida con el de ldap
addgroup --gid 999 docker

systemctl start sssd

systemctl enable docker

systemctl start docker
