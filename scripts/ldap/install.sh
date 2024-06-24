#!/bin/bash
#
# Instala SSSD para tener login al servidor LDAP
# Para vaciar la cache de SSSD:
#   $ sss_cache -E
#   $ sss_cache -u diurno
#

source ../functions.sh

apt-get install -y sssd-ldap ldap-utils libsss-sudo sssd-tools
install -o root -g root -m 0600 -t /etc/sssd/ -D sssd.conf
systemctl restart sssd.service

# Create user home dir (from /etc/skel) at login if not exists
pam-auth-update --enable mkhomedir
ensure_line_in_file /etc/pam.d/common-session pam_mkhomedir.so 'session optional			pam_mkhomedir.so umask=077'

# Instalar ldap.conf no es necesario pero configura herramientas de diagnostico
# como ldapsearch, ldapwhoami...
mkdir -p /etc/ldap
install -o root -g root -m 0644 -t /etc/ldap/ -D ldap.conf


# Deshabilita la configuración de scripts/auth para poder inicializar los usuarios
# Este script en principio se ejecuta antes que scripts/auth, pero podemos
# estar ejecutando la instalacion una segunda vez.
pam-auth-update --remove tierno-login-time


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

# Conviene reiniciar sesión
