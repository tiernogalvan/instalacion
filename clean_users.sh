#!/bin/bash

systemctl stop sssd

sss_cache -E

rm -rf /home/diurno
rm -rf /home/vespertino

systemctl start sssd

inicializar_usuario() {
  user="$1"

  # Primer login del usuario
  # Ejecuta pam_mkhomedir copiando /etc/skel al home del usuario, necesario para el resto de la instalación
  # Cuando entre gráficamente ya se crearán los directorios de escritorio etc.
  su - $user -s /bin/bash -c 'echo "Primer login con usuario $(whoami)"'

  # Para que aparezca el usuario en login grafico GDM
  touch /var/lib/AccountsService/users/$user
}

inicializar_usuario diurno
inicializar_usuario vespertino

