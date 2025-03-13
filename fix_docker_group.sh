#!/bin/bash
# Cambia el gid de docker a 600

if [[ $(cat /etc/group | grep docker | grep :600: | wc -l) -eq 0 ]]; then
	
	# Se detiene LDAP client
  	systemctl stop sssd

	# Se eliminan los grupos cacheados
	sss_cache -E

	# Se modifica el grupo para que tenga GID 600
	groupmod -g 600 docker

	# Se arranca LDAP client
	systemctl start sssd

	echo "Reiniciando..."
    reboot
else
	 if [[ $(cat /etc/group | grep docker | grep :600: | wc -l) -eq 0 ]]; then
	 	# Se detiene LDAP client
	  	systemctl stop sssd

		# Se eliminan los grupos cacheados
		sss_cache -E

		# Creación de grupo docker con GID 600
		addgroup --gid 600 docker

		# Se arranca LDAP client
		systemctl start sssd

		echo "Reiniciando..."
    	reboot
	 else
	 	echo La configuración actual es correcta
	 fi
fi