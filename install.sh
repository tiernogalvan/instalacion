#!/bin/bash

die() { echo "$*" 1>&2 ; exit 1; }

if [[ "$EUID" -ne 0 ]]; then
  die "Please run as root"
fi

# Ejecuta la instalación desde el propio directorio
run_install() {
  pushd .
  cd scripts/$1
  ./install.sh
  popd
}

run_install apt
run_install ssh
run_install ldap
run_install base

