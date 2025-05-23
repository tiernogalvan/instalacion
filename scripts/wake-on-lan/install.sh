#!/bin/bash
# Los PCs blancos de la B27 soportan Wake On Lan, pero se desactiva
# en cada arranque y hay que configurarlo siempre. Esto lo automatiza.
# No debería ser dañino para el resto de equipos.
# TODO: testear en equipos blancos y en el resto.

bash ./wol-networkd.sh
bash ./wol-netplan.sh
