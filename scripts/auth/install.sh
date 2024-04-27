#!/bin/bash
# Asegura que los usuarios diurno y vespertino solo pueden loguearse en sus turnos horarios.
#
# Este script es algo frágil y habría que pasarlo a ansible.
# Si alguien cambia estas líneas a mano este script añadiría nuevas reglas en vez de sustituirlas.
#

ensure_line_in_file () {
  file="$1"
  line="$2"
  if [[ ! $(grep "$line" "$file") ]]; then
    echo Not in file
    echo "$line" >> $file
  fi
}

ensure_line_in_file /etc/security/time.conf   '* ; * ; diurno ; Al0800-1500'
ensure_line_in_file /etc/security/time.conf   '* ; * ; vespertino ; Al1500-2200'
ensure_line_in_file /etc/pam.d/common-account 'account required pam_time.so'
