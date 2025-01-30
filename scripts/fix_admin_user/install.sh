#!/bin/bash
#
# This script should be run in a fresh installation of Ubuntu 22.04
#

if [[ $SUDO_USER != "administrator" ]]; then

	echo Nombre de usuario $SUDO_USER incorrecto, renombrando a administrator
	systemc
	groupadd administrator
	usermod -d /home/administrator -m -g administrator -l administrator $SUDO_USER

fi