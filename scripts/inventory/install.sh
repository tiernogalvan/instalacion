#!/usr/bin/env bash
# ============================================================
# install-ocs-agent.sh — Instalar agente OCS Inventory
# Ejecutar como root o con sudo
# ============================================================
set -euo pipefail

OCS_SERVER="http://inventory.lan.tierno.es:8081/ocsinventory"

# Extraer nombre corto y TAG del hostname
# b22-a1.lan.tierno.es → nombre: b22-a1, TAG: B22
HOSTNAME_SHORT=$(hostname -s)
TAG=$(echo "${HOSTNAME_SHORT}" | cut -d'-' -f1 | tr '[:lower:]' '[:upper:]')

echo "Máquina: ${HOSTNAME_SHORT}"
echo "TAG:     ${TAG}"

# Comprobar que se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Ejecutar como root o con sudo"
    exit 1
fi

# Comprobar si ya está instalado
if dpkg -l ocsinventory-agent &>/dev/null; then
    echo "OCS Inventory Agent ya está instalado."
    exit 0
fi

echo "=== Instalando OCS Inventory Agent ==="

# Añadir repositorio OCS
curl -fsSL https://deb.ocsinventory-ng.org/pubkey.gpg \
    | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/ocs-archive-keyring.gpg

echo "deb http://deb.ocsinventory-ng.org/ubuntu/ noble main" \
    | tee /etc/apt/sources.list.d/ocsinventory.list > /dev/null

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y ocsinventory-agent

# Configurar agente
mkdir -p /etc/ocsinventory-agent
cat > /etc/ocsinventory-agent/ocsinventory-agent.cfg <<EOF
server=${OCS_SERVER}
basevardir=/var/lib/ocsinventory-agent
logfile=/var/log/ocsinventory-agent.log
tag=${TAG}
ssl=0
debug=0
EOF

echo "=== Forzando primer inventario ==="
ocsinventory-agent

echo ""
echo "=========================================="
echo " Agente OCS instalado y configurado."
echo " Servidor: ${OCS_SERVER}"
echo " TAG:      ${TAG}"
echo " Inventario enviado."
echo "=========================================="