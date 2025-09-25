#!/bin/bash

source ../functions.sh


if [[ $(dpkg -l | grep veyon | wc -l) -eq 0 ]]; then
  # IMPRESCINDIBLE:
  # Deshabilita Wayland para arrancar en Xorg. Necesario reiniciar
  # Para comprobarlo: `echo $XDG_SESSION_TYPE` debe poner x11, no wayland
  ensure_line_in_file /etc/gdm3/custom.conf WaylandEnable 'WaylandEnable=false'

  # Universe es imprescindible para las dependencias de veyon
  add-apt-repository -y universe

  add-apt-repository -y ppa:veyon/stable
  # Ojo!! No instalar los paquetes veyon-* (incompatibles con paquete veyon)
  apt-get install -y veyon

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
fi

bash -c 'set -e; d=/etc/systemd/system/veyon.service.d; f=$d/override.conf; mkdir -p "$d"; cat >"$f" <<EOF
[Unit]
Wants=network-online.target
After=network-online.target

[Service]
Restart=always
RestartSec=5s
EOF
systemctl daemon-reload
systemctl try-restart veyon.service
systemctl enable veyon.service >/dev/null
systemctl list-unit-files | grep -q "^NetworkManager-wait-online.service" && systemctl enable NetworkManager-wait-online.service >/dev/null || true
systemctl list-unit-files | grep -q "^systemd-networkd-wait-online.service" && systemctl enable systemd-networkd-wait-online.service >/dev/null || true
'



# Instalamos la clave pública de nuestro aula
aula=$(hostname | cut -d- -f1)  # Ej: B21-A1 queda en B21
aula_key="./keys/${aula}_public_key.pem"
if [[ -f $aula_key ]]; then
  install -o root -g root -m 0444 -D $aula_key /etc/veyon/keys/public/${aula}/key
fi
