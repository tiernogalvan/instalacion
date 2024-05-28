#!/bin/bash
# Los PCs blancos de la B27 soportan Wake On Lan, pero se desactiva
# en cada arranque y hay que configurarlo siempre. Esto lo automatiza.
# No debería ser dañino para el resto de equipos.
# TODO: testear en equipos blancos y en el resto.

dev=$(ip route show default | awk '/default via [0-9\.]* dev/ {print $5}' | sort | uniq | head -n1)
mac=$(cat /sys/class/net/${dev}/address)

cat <<EOF
[Match]
MACAddress=$mac

[Link]
NamePolicy=kernel database onboard slot path
MACAddressPolicy=persistent
WakeOnLan=magic
EOF > /etc/systemd/network/50-wakeonlan.link
