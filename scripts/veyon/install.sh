#!/bin/bash

source ../functions.sh

# IMPRESCINDIBLE:
# Deshabilita Wayland para arrancar en Xorg. Necesario reiniciar
# Para comprobarlo: `echo $XDG_SESSION_TYPE` debe poner x11, no wayland
ensure_line_in_file /etc/gdm3/custom.conf WaylandEnable 'WaylandEnable=false'

add-apt-repository -y ppa:veyon/stable
apt-get remove -y veyon-*
apt-get install -y veyon veyon-master veyon-cli veyon-configurator

veyon-cli config import ./veyon-config-client.json

# Habilitar Veyon solo para profesores
chmod o-rwx /usr/share/applications/veyon-*
chmod o-rwx /bin/veyon-cli
chmod o-rwx /bin/veyon-master
chmod o-rwx /bin/veyon-configurator
chgrp $PROFESORES_GID /usr/share/applications/veyon-*
chgrp $PROFESORES_GID /bin/veyon-cli
chgrp $PROFESORES_GID /bin/veyon-master
chgrp $PROFESORES_GID /bin/veyon-configurator

# Instalamos la clave pública de nuestro aula
aula=$(hostname | cut -d- -f1)  # Ej: B21-A1 queda en B21
aula_key="./keys/${aula}_public_key.pem"
if [[ -f $aula_key ]]; then
  install -o root -g root -m 0444 -D $aula_key /etc/veyon/keys/public/${aula}/key
fi
