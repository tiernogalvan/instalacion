#!/bin/bash

# Deshabilitamos el login local de administrator
# Esto hace que solo funcione el password de LDAP
passwd -l administrator

if [[ $( grep -n 1000:1000: /etc/passwd | wc -l ) -eq 1 ]]; then
	# Elimina todos los usuarios locales creados después de administrator 
	let SKIP=1+$(grep -n 1000:1000: /etc/passwd | awk -F : '{ print $1 }')
	tail -n +$SKIP /etc/passwd | awk -F : '{ print $1 }' | xargs -I {} userdel -r {}
fi
