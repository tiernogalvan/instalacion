#!/bin/bash

die() { echo "$*" 1>&2 ; exit 1; }

if [[ "$EUID" -ne 0 ]]; then
  die "Please run as root."
fi

clear

echo
echo
echo "  _   _                                   _                  "
echo " | |_(_) ___ _ __ _ __   ___   __ _  __ _| |_   ____ _ _ __  "
echo " | __| |/ _ \ '__| '_ \ / _ \ / _\` |/ _\` | \ \ / / _\` | '_ \ "
echo " | |_| |  __/ |  | | | | (_) | (_| | (_| | |\ V / (_| | | | |"
echo "  \__|_|\___|_|  |_| |_|\___/ \__, |\__,_|_| \_/ \__,_|_| |_|"
echo "                              |___/                          "
echo
echo "IES Enrique Tierno Galván"
echo "Asistente de instalación de equipo."
echo

rootpath="$(pwd)"
run_install() {
  # Use absolute path in case some script changed directory
  cd ${rootpath}/scripts/$1
  bash ./install.sh
}

run_install hostname  # Must be first
echo "Comenzando instalación..."
echo

run_install apt
run_install ssh
run_install ldap
run_install auth # Después de ldap
run_install bash
run_install resolve
run_install apps
run_install containers
run_install veyon
run_install cron

echo "Fin del script :)"
echo "Debes reiniciar el sistema."
