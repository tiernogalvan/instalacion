#!/bin/bash
#
# Configura el DHCP client para que no acepte IPs de fuera de rango
# Script idempotente para Ubuntu 24.04 - Solo acepta DHCP de 172.20.0.2
#

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para log
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en Ubuntu 24.04
check_ubuntu_version() {
    if [ ! -f /etc/os-release ]; then
        log_error "No se puede determinar la distribución"
        exit 1
    fi
    
    . /etc/os-release
    if [ "$ID" != "ubuntu" ] || [ "$VERSION_ID" != "24.04" ]; then
        log_warn "Este script está diseñado para Ubuntu 24.04. Detectado: $ID $VERSION_ID"
        read -p "¿Continuar de todos modos? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Instalar dhclient si no está presente
install_dhclient() {
    if ! command -v dhclient &> /dev/null; then
        log_info "Instalando dhclient..."
        apt-get update
        apt-get install -y isc-dhcp-client
    else
        log_info "dhclient ya está instalado"
    fi
}

# Configurar dhclient para rechazar todas las respuestas excepto de 172.20.0.2
configure_dhclient() {
    local dhclient_conf="/etc/dhcp/dhclient.conf"
    
    # Crear directorio si no existe
    mkdir -p "$(dirname "$dhclient_conf")"
    
    # Verificar si la configuración ya está aplicada
    local config_applied=false
    if [ -f "$dhclient_conf" ]; then
        if grep -q "reject 0.0.0.0/0;" "$dhclient_conf" && \
           grep -q "server-identifier 172.20.0.2;" "$dhclient_conf"; then
            log_info "La configuración de dhclient ya está aplicada"
            config_applied=true
        fi
    fi
    
    if [ "$config_applied" = false ]; then
        log_info "Configurando dhclient para aceptar solo respuestas de 172.20.0.2..."
        
        # Crear backup de la configuración existente
        if [ -f "$dhclient_conf" ]; then
            cp "$dhclient_conf" "${dhclient_conf}.backup.$(date +%Y%m%d%H%M%S)"
            log_info "Backup creado: ${dhclient_conf}.backup.$(date +%Y%m%d%H%M%S)"
        fi
        
        # Crear nueva configuración
        cat > "$dhclient_conf" << 'EOF'
# Configuración dhclient para aceptar solo respuestas de 172.20.0.2
# Generado automáticamente por scripts/dhcp/install.sh

# Rechazar todas las direcciones IP por defecto
reject 0.0.0.0/0;

# Permitir solo el servidor específico
server-identifier 172.20.0.2;

# Configuraciones adicionales para mejor rendimiento
timeout 60;
retry 60;
reboot 10;
select-timeout 5;
initial-interval 2;

# Opciones DHCP a solicitar
request subnet-mask, broadcast-address, time-offset, routers,
    domain-name, domain-name-servers, domain-search, host-name,
    netbios-name-servers, netbios-scope, interface-mtu,
    rfc3442-classless-static-routes, ntp-servers;

# Enviar opciones específicas
send host-name = gethostname();
send dhcp-client-identifier = concat(00, hardware);
EOF
        
        log_info "Configuración de dhclient aplicada"
    fi
}

# Habilitar y reiniciar el servicio dhclient
enable_dhclient_service() {
    log_info "Verificando servicios de red..."
    
    # Detener cualquier instancia de dhclient en ejecución
    if pgrep dhclient > /dev/null; then
        log_info "Deteniendo instancias de dhclient en ejecución..."
        pkill dhclient || true
        sleep 2
    fi
    
    # Para systemd-networkd
    if systemctl is-active --quiet systemd-networkd; then
        log_info "Reiniciando systemd-networkd..."
        systemctl restart systemd-networkd
    fi
    
    # Para NetworkManager
    if systemctl is-active --quiet NetworkManager; then
        log_info "Reiniciando NetworkManager..."
        systemctl restart NetworkManager
    fi
    
    log_info "Los servicios de red han sido reiniciados para aplicar la configuración"
}

# Verificar la configuración aplicada
verify_configuration() {
    log_info "Verificando configuración..."
    
    if [ ! -f "/etc/dhcp/dhclient.conf" ]; then
        log_error "El archivo de configuración no se creó"
        return 1
    fi
    
    if ! grep -q "reject 0.0.0.0/0;" "/etc/dhcp/dhclient.conf"; then
        log_error "La regla 'reject 0.0.0.0/0;' no está presente"
        return 1
    fi
    
    if ! grep -q "server-identifier 172.20.0.2;" "/etc/dhcp/dhclient.conf"; then
        log_error "La regla 'server-identifier 172.20.0.2;' no está presente"
        return 1
    fi
    
    log_info "✓ Configuración verificada correctamente"
    log_info "  - dhclient rechazará todas las respuestas DHCP excepto de 172.20.0.2"
    
    return 0
}

# Mostrar estado actual
show_status() {
    log_info "=== Estado actual del sistema ==="
    
    # Verificar si dhclient está instalado
    if command -v dhclient &> /dev/null; then
        log_info "✓ dhclient está instalado"
        dhclient --version | head -1
    else
        log_warn "✗ dhclient NO está instalado"
    fi
    
    # Verificar configuración
    if [ -f "/etc/dhcp/dhclient.conf" ]; then
        log_info "✓ Archivo de configuración existe: /etc/dhcp/dhclient.conf"
        
        if grep -q "reject 0.0.0.0/0;" "/etc/dhcp/dhclient.conf"; then
            log_info "  ✓ Configuración 'reject 0.0.0.0/0;' presente"
        else
            log_warn "  ✗ Configuración 'reject 0.0.0.0/0;' NO presente"
        fi
        
        if grep -q "server-identifier 172.20.0.2;" "/etc/dhcp/dhclient.conf"; then
            log_info "  ✓ Configuración 'server-identifier 172.20.0.2;' presente"
        else
            log_warn "  ✗ Configuración 'server-identifier 172.20.0.2;' NO presente"
        fi
    else
        log_warn "✗ Archivo de configuración NO existe"
    fi
    
    # Verificar procesos en ejecución
    if pgrep dhclient > /dev/null; then
        log_info "✓ dhclient está en ejecución"
    else
        log_info "  dhclient NO está en ejecución (puede ser normal si usa NetworkManager)"
    fi
}

# Función principal
main() {
    log_info "Iniciando configuración idempotente de dhclient para Ubuntu 24.04"
    
    # Verificar permisos
    if [ "$EUID" -ne 0 ]; then
        log_error "Este script debe ejecutarse como root"
        exit 1
    fi
    
    # Mostrar estado actual
    show_status
    
    check_ubuntu_version
    install_dhclient
    configure_dhclient
    enable_dhclient_service
    verify_configuration
    
    log_info ""
    log_info "Configuración completada exitosamente"
    log_info "El script es idempotente y puede ejecutarse nuevamente sin problemas"
    log_info ""
    log_info "Resumen:"
    log_info "  - dhclient instalado y configurado"
    log_info "  - Solo aceptará respuestas DHCP de 172.20.0.2"
    log_info "  - Todas las demás respuestas serán rechazadas"
}

# Manejar argumentos
case "${1:-}" in
    status)
        show_status
        ;;
    help|--help|-h)
        echo "Uso: $0 [comando]"
        echo ""
        echo "Comandos:"
        echo "  (sin comando)  Aplicar configuración dhclient"
        echo "  status         Mostrar estado actual"
        echo "  help           Mostrar esta ayuda"
        echo ""
        echo "Descripción:"
        echo "  Configura dhclient para rechazar todas las respuestas DHCP"
        echo "  excepto las del servidor 172.20.0.2"
        echo "  Script idempotente para Ubuntu 24.04"
        ;;
    *)
        main "$@"
        ;;
esac

