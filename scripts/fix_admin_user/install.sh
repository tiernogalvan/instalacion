#!/bin/bash
#
# This script should be run in a fresh installation of Ubuntu 22.04
#

if [[ $USER != "administrator" ]]; then

	echo Nombre de usuario $USER incorrecto, renombrando a administrator
	groupadd administrator
	usermod -d /home/administrator -m -g administrator -l administrator $USER

fi