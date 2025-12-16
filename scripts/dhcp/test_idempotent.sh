#!/bin/bash
#
# Script de prueba para demostrar la idempotencia del script de DHCP
#

echo "=== Prueba de idempotencia del script DHCP ==="
echo ""

# Primera ejecución
echo "1. Primera ejecución (debería instalar y configurar):"
echo "-----------------------------------------------"
sudo ./install.sh 2>&1 | grep -E '(INFO|WARN|ERROR|Configuración completada)'
echo ""

# Esperar un momento
sleep 2

# Segunda ejecución
echo "2. Segunda ejecución (debería mostrar que ya está configurado):"
echo "---------------------------------------------------------------"
sudo ./install.sh 2>&1 | grep -E '(INFO|WARN|ERROR|Configuración completada|ya está)'
echo ""

# Tercera ejecución con status
echo "3. Verificación de estado:"
echo "-------------------------"
sudo ./install.sh status 2>&1 | grep -E '(INFO|WARN|ERROR|✓|✗)'
echo ""

echo "=== Prueba completada ==="
echo ""
echo "Si el script es idempotente, la segunda ejecución debería mostrar"
echo "que la configuración ya está aplicada y no realizar cambios."