#!/bin/bash
# Asegura que los usuarios diurno y vespertino solo pueden loguearse en sus turnos horarios.
#
# Este script es algo frágil y habría que pasarlo a ansible.
# Si alguien cambia estas líneas a mano este script añadiría nuevas reglas en vez de sustituirlas.
#

source ../functions.sh

ensure_line_in_file /etc/security/time.conf diurno     '* ; * ; diurno     ; Al0800-1500'
ensure_line_in_file /etc/security/time.conf vespertino '* ; * ; vespertino ; Al1500-2200'

# Aquí activamos pam_time.
# En caso login denegado ejecutamos tierno_pam_time_denied.sh para mostrar mensaje de error personalizado.
# `success=1` ignora la siguiente línea en caso de login exitoso. Ver `man pam.conf`
install -o root -g root -m 0750 -t /usr/local/sbin/ -D tierno_pam_time_denied.sh

# Configuración antigua:
# ensure_line_in_file /etc/pam.d/common-account pam_time.so 'account [success=1 new_authtok_reqd=ok ignore=ignore default=bad] pam_time.so debug'
# ensure_line_in_file /etc/pam.d/common-account tierno_pam_time_denied.sh 'account [default=ignore] pam_exec.so stdout /usr/local/sbin/tierno_pam_time_denied.sh'
#
# Borrar la configuración antigua
sed -i '/pam_time.so/d' /etc/pam.d/common-account
sed -i '/tierno_pam_time_denied.sh/d' /etc/pam.d/common-account

# Nueva configuración
install -o root -g root -m 0644 -t /usr/share/pam-configs/ -D tierno-login-time
pam-auth-update --enable tierno-login-time
