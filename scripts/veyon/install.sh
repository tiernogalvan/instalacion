#!/bin/bash

source ../functions.sh

# IMPRESCINDIBLE:
# Deshabilita Wayland para arrancar en Xorg. Necesario reiniciar
# Para comprobarlo: `echo $XDG_SESSION_TYPE` debe poner x11, no wayland
ensure_line_in_file /etc/gdm3/custom.conf WaylandEnable 'WaylandEnable=false'

add-apt-repository -y ppa:veyon/stable
apt-get install -y veyon

install -o root -g root -m 0444 -D ./aula_public_key.pem /etc/veyon/keys/public/aula/key

veyon-cli config import ./veyon-config-client.json

# Habilitar Veyon solo para profesores
chmod o-rwx /usr/share/applications/veyon-*
chmod o-rwx /bin/veyon-*
chgrp $PROFESORES_GID /usr/share/applications/veyon-*
chgrp $PROFESORES_GID /bin/veyon-*
