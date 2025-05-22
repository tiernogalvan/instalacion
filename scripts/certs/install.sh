#!/bin/bash
#
# Esto instala un certificado de una autoridad certificadora (CA) raíz interna.
# Permite que se confíe en certificados generados por esta CA en servidores internos.
#
cp ./tierno-root-ca.crt /usr/local/share/ca-certificates/
update-ca-certificates
