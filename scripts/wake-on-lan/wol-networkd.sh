#!/bin/bash
# Este script activa Wake On Lan en sistemas con systemd-networkd
#

dev=$(ip route show default | awk '/default via [0-9\.]* dev/ {print $5}' | sort | uniq | head -n1)
mac=$(cat /sys/class/net/${dev}/address)

cat > /etc/systemd/network/50-wakeonlan.link <<EOF
[Match]
MACAddress=$mac

[Link]
NamePolicy=kernel database onboard slot path
MACAddressPolicy=persistent
WakeOnLan=magic
EOF
