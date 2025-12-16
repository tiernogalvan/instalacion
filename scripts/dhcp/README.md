# DHCP Configuration Scripts

Scripts para configurar dhclient en Ubuntu 24.04 para aceptar solo respuestas DHCP del servidor 172.20.0.2.

## Archivos

- `install.sh` - Script principal idempotente
- `dhclient.conf` - Configuración de dhclient

## Características

- **Idempotente**: Puede ejecutarse múltiples veces sin efectos secundarios
- **Específico para Ubuntu 24.04**: Verifica la versión del sistema
- **Configuración segura**: Solo acepta DHCP de 172.20.0.2
- **Verificación**: Incluye checks de estado y validación

## Uso

```bash
# Mostrar ayuda
sudo ./install.sh help

# Mostrar estado actual
sudo ./install.sh status

# Aplicar configuración (requiere root)
sudo ./install.sh
```

## Configuración aplicada

El script configura dhclient para:

1. **Rechazar todas las respuestas DHCP** excepto de 172.20.0.2
2. **Instalar dhclient** si no está presente
3. **Crear configuración** en `/etc/dhcp/dhclient.conf`
4. **Reiniciar servicios de red** para aplicar cambios

## Verificación

El script incluye verificación automática que confirma:
- Presencia de la regla `reject 0.0.0.0/0;`
- Presencia de la regla `server-identifier 172.20.0.2;`
- Archivo de configuración creado correctamente

## Idempotencia

El script verifica el estado actual antes de realizar cambios:
- Si dhclient ya está instalado, no lo reinstala
- Si la configuración ya está aplicada, no la modifica
- Crea backups antes de modificar archivos existentes
