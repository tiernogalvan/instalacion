#!/bin/bash
# Permite resolver nombres de otros hosts sin escribir el FQDN completo.
# Ej: ping B21-A1                        (con este sccript es posible)
# Ej: ping B21-A1.lan.tiernogalvan.es    (no es necesario)

install -o root -g root -m 0644 -t /etc/systemd/resolved.conf.d/ -D tierno.conf
systemctl restart systemd-resolved.service
