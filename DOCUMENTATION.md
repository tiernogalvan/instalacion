# Documentación del script de instalación

Sistema de aprovisionamiento automatizado de los equipos de alumnos del **IES Enrique Tierno Galván** (Madrid). Es una colección de scripts Bash que dejan un Ubuntu 24.04 recién instalado totalmente configurado e integrado en la infraestructura del centro: identidad LDAP, restricciones horarias, software docente, control de aula (Veyon), inventario, caché de paquetes, etc.

- **Lenguaje:** Shell (100 %)
- **SO objetivo:** Ubuntu 24.04 LTS (con compatibilidad parcial con 22.04)
- **Licencia:** GPL-3.0
- **Ejecución:** siempre como `root`, con el usuario `sudo` `administrator`

---

## 1. Inicio rápido

### Instalación automática (recomendada)

```bash
wget -qO- https://raw.githubusercontent.com/tiernogalvan/instalacion/refs/heads/main/bootstrap.sh | sudo bash
```

### Instalación manual

```bash
sudo apt-get install -y git
git clone https://github.com/tiernogalvan/instalacion.git
cd instalacion
sudo bash ./install.sh
```

### Reparar el GID del grupo docker

```bash
wget -qO- https://raw.githubusercontent.com/tiernogalvan/instalacion/main/fix_docker_group.sh | sudo bash
```

---

## 2. Arquitectura

El flujo es siempre el mismo: un *bootstrap* descarga el repositorio y lanza el orquestador `install.sh`, que ejecuta secuencialmente los módulos de `scripts/`. Cada módulo es una carpeta autocontenida con su propio `install.sh` y sus ficheros de configuración.

```
bootstrap*.sh  →  install.sh  →  scripts/<modulo>/install.sh  (×16)
   (descarga)     (orquesta)      (configura cada área)
```

### Puntos de entrada

| Script | Modo | Descripción |
| --- | --- | --- |
| `bootstrap.sh` | Interactivo | Descarga el repo como ZIP, ejecuta `install.sh -r` redirigiendo a `/dev/tty` (para que funcione vía *pipe*), limpia y **reinicia** al terminar. |
| `bootstrap-unattended.sh` | Desatendido | Igual que el anterior pero llama a `install.sh -y`. Admite `-h <hostname>` para fijar el nombre sin preguntar. |
| `install.sh` | Orquestador | El núcleo. Parsea argumentos, valida el usuario, fija el hostname y ejecuta todos los módulos en orden, con barra de progreso *Zenity* si hay entorno gráfico. |
| `install-nogui.sh` | Legado | Variante sin Zenity con un orden de pasos ligeramente distinto. Se mantiene como alternativa de respaldo. |

### Argumentos de `install.sh`

| Flag | Efecto |
| --- | --- |
| `-y` | Modo automático: no pide confirmaciones (omite la validación del usuario `administrator` y la confirmación de hostname si ya es válido). |
| `-s` | Apagar al finalizar (`shutdown -h +1`). |
| `-r` | Reiniciar al finalizar (`shutdown -r +1`). |
| `-h <hostname>` | Fija el hostname directamente, sin preguntar. |

### Validaciones previas

`install.sh` exige ejecutarse como `root` y que el usuario `sudo` sea `administrator` (salvo en modo `-y`). Si la instalación de Ubuntu creó un usuario distinto con UID/GID 1000, hay que corregirlo antes con `fix_administrator.sh`.

### Reporte final

Tras ejecutar todos los pasos, lanza un `apt install --fix-missing`, `autoremove` y `autoclean`, e imprime un informe coloreado con `[ OK ]` / `[FAIL]` por cada módulo. Si hubo algún fallo, termina con error.

---

## 3. Orden de ejecución de los módulos

Este es el orden definitivo que usa `install.sh` (el orden importa: hay dependencias entre módulos).

| # | Módulo | Propósito |
| --- | --- | --- |
| 0 | `hostname` | Determina/establece el nombre del equipo. **Siempre el primero.** |
| 1 | `apt` | Configura APT, proxy de caché y paquetes base. |
| 2 | `gnome-extensions` | Extensión que muestra info del host en GNOME. Antes de LDAP. |
| 3 | `certs` | Instala la CA raíz interna del centro. |
| 4 | `local-users` | Bloquea el login local de `administrator`. |
| 5 | `ldap` | Cliente SSSD contra el LDAP del centro. |
| 6 | `auth` | Restricción horaria de login (`pam_time`). Después de LDAP. |
| 7 | `dhcp` | Endurece el cliente DHCP para aceptar solo el servidor del centro. |
| 8 | `bash` | Defaults de shell, `.bashrc`, `.gitconfig`, `umask`. |
| 9 | `resolve` | Resolución de nombres cortos (dominio de búsqueda `tierno.es`). |
| 10 | `apps` | Todo el software docente (APT + Snap + .deb). |
| 11 | `containers` | Docker daemon y contenedores de BBDD por turno. |
| 12 | `veyon` | Control de aula para profesores. |
| 13 | `inventory` | Agente OCS Inventory. |
| 14 | `cron` | Tareas programadas (apagado nocturno, inventario diario). |
| 15 | `wake-on-lan` | Activa Wake-on-LAN en las interfaces. |
| 16 | `ssh` | Servidor SSH y claves autorizadas. |

> El orden de `install-nogui.sh` difiere ligeramente (coloca `ssh` antes y omite `inventory`); se considera la ruta de respaldo.

---

## 4. Infraestructura del centro

Los scripts asumen una red `172.20.0.0/24` con estos servicios. Conviene tenerlos presentes al leer los módulos:

| Servicio | Dirección | Usado por |
| --- | --- | --- |
| Servidor DHCP | `172.20.0.2` | módulo `dhcp` |
| Caché APT (apt-cacher-ng) | `172.20.0.21:3142` | módulo `apt` |
| Proxy Snap Store | `172.20.0.21` | `apps` (actualmente deshabilitado) |
| LDAP | `ldaps://ldap.tierno.es` | módulos `ldap`, `auth` |
| API de registro de hostname | `https://tierno.es/hostname/...` | módulo `hostname` |
| OCS Inventory | `http://inventory.lan.tierno.es:8081/ocsinventory` | módulo `inventory` |
| Registro Docker interno | `proxy-docker.tierno.es:5000` | módulo `containers` |
| FTP de software | `ftp.lan.tierno.es` (`alumno`) | módulo `apps` |

### Usuarios y grupos

| Usuario / Grupo | GID | Notas |
| --- | --- | --- |
| `administrator` | 1000 | Admin local; su contraseña local se **bloquea** (solo entra por LDAP). |
| `diurno` | (alumno) | Usuario de turno de mañana. |
| `vespertino` | (alumno) | Usuario de turno de tarde. |
| `profesores` | `10000` | Definido en `functions.sh` como `PROFESORES_GID`. |
| `alumnos` | `10001` | Definido en `functions.sh` como `ALUMNOS_GID`. |
| `docker` | `600` | Forzado a GID 600 para coincidir con el LDAP. |

### Convención de hostname

Formato `B<aula>-<puesto>`:

- **Aulas válidas:** `B15`, `B17`, `B21`, `B22`, `B23`, `B24`, `B25`, `B27`, `B32`.
- **Puestos:** `A1`…`J7` (regex `[A-J][0-7]`) o `PROFESOR`.
- Ejemplos: `B21-A1`, `B27-PROFESOR`.

---

## 5. Biblioteca común — `scripts/functions.sh`

Funciones y constantes compartidas que los módulos cargan con `source ../functions.sh`.

- `PROFESORES_GID=10000`, `ALUMNOS_GID=10001` — GIDs del LDAP.
- `ensure_line_in_file <fichero> <patrón> <línea>` — utilidad **idempotente** clave: si encuentra el patrón, sustituye esa línea por la indicada; si no, la añade al final. Se usa para editar `pam.d`, `gdm3`, `time.conf`, etc., sin duplicar reglas.

---

## 6. Detalle de los módulos

### `hostname` — Identidad del equipo

Establece el nombre del equipo de tres formas posibles, por orden de prioridad:

1. **Por parámetro** (`-h <hostname>`): lo aplica directamente.
2. **Autodetección**: comprueba el `hostname` actual y las resoluciones DNS inversas de la IP principal; si alguno encaja con el patrón `B##-PUESTO` lo confirma (o lo da por bueno con `-y`).
3. **Manual**: pregunta aula y puesto por teclado, validando contra la lista de aulas/puestos conocidos.

Una vez fijado con `hostnamectl`, **registra el equipo en el servidor** enviando `https://tierno.es/hostname/<hostname>/<MAC>` por cada interfaz con ruta por defecto.

### `apt` — Gestor de paquetes y caché

- Instala `01proxy.conf` y el script `apt-proxy-detect.sh` en el sistema.
- **Detección automática de proxy:** `apt-proxy-detect.sh` comprueba si el servidor caché (`172.20.0.21:3142`) está vivo; si responde lo usa, si no hace *fallback* a descarga directa (`DIRECT`) y lo registra en `/var/log/apt/apt-proxy-detect.log`. Pensado para soportar varios servidores caché con *shuffle*.
- Instala utilidades base: `git`, `curl`, `wget`, `vim`, `fzf`, `btop`, `htop`, `duf`, `ncdu`, `pipx`, etc.
- Fija `release-upgrades` con `Prompt=never` para que no ofrezca saltos de versión.
- Estadísticas del caché: `172.20.0.21:3142/acng-report.html`.

### `gnome-extensions` — Info del host en el escritorio

Instala la extensión [`gnome-extension-tierno-host-info`](https://github.com/tiernogalvan/gnome-extension-tierno-host-info) descargando su `install-system.sh`. Se ejecuta antes de LDAP.

### `certs` — Autoridad certificadora interna

Copia `tierno-root-ca.crt` a `/usr/local/share/ca-certificates/` y ejecuta `update-ca-certificates --fresh`, de modo que el sistema confíe en los certificados de los servidores internos.

### `local-users` — Endurecimiento de cuentas locales

`passwd -l administrator`: bloquea la contraseña **local** de `administrator`, forzando que solo sea válida la del LDAP. (Conserva comentado un bloque para borrar usuarios locales creados tras `administrator`.)

### `ldap` — Cliente de identidad (SSSD)

- Instala `sssd-ldap`, `ldap-utils`, `libsss-sudo`, `sssd-tools`.
- Despliega `sssd.conf` (dominio `tierno.es`, `ldaps://ldap.tierno.es`, esquema `rfc2307bis`, `enumerate = false` por privacidad).
- Habilita `pam_mkhomedir` para crear el *home* desde `/etc/skel` en el primer login (con `umask=077`).
- Instala `ldap.conf` para herramientas de diagnóstico (`ldapsearch`, `ldapwhoami`).
- **Inicializa** los usuarios `diurno`, `vespertino` y `administrator` haciendo un primer login que crea sus *homes* y los hace visibles en GDM.
- Limpieza de caché útil en mantenimiento: `sss_cache -E`, `sss_cache -u diurno`.

### `auth` — Restricción horaria de login

Limita los turnos mediante `pam_time`:

- `diurno`: lunes a sábado **08:00–15:30** (`Al0800-1530`).
- `vespertino`: lunes a sábado **14:30–22:00** (`Al1430-2200`).

Define el perfil `tierno-login-time` en `/usr/share/pam-configs/` (activado con `pam-auth-update`). Si el login se deniega por horario, el script `tierno_pam_time_denied.sh` muestra un mensaje claro indicando la franja permitida del usuario. El propio módulo limpia configuraciones antiguas en `common-account` antes de aplicar la nueva.

> Nota del autor: este módulo es algo frágil y sería candidato a migrar a Ansible.

### `dhcp` — Cliente DHCP endurecido

Configura `dhclient` para **aceptar solo respuestas del servidor `172.20.0.2`** (`reject 0.0.0.0/0; server-identifier 172.20.0.2;`), evitando servidores DHCP intrusos. Es totalmente idempotente: detecta si ya está aplicado, hace backup con marca de tiempo antes de modificar y verifica el resultado. Subcomandos: `status` y `help`.

### `bash` — Entorno de shell por defecto

Instala en `/etc/skel/` (plantilla de nuevos usuarios) un `.bashrc` y un `.gitconfig` (con alias `git lg` para un log gráfico), y en `/etc/profile.d/` un `default-umask.sh` que fija **`umask 077`** — importante porque `diurno` y `vespertino` comparten el GID de `alumno` y así se protegen sus ficheros entre sí.

### `resolve` — Resolución de nombres cortos

Añade `Domains=tierno.es` a `systemd-resolved`, permitiendo `ping B21-A1` en lugar del FQDN completo `B21-A1.lan.tierno.es`.

### `apps` — Software docente

El módulo más extenso. Instala (de forma condicional/idempotente):

- **APT:** OpenJDK 21, Maven, `mysql-client-8.0`, `postgresql-client`, LibreOffice (es), Neovim, ranger, `zsh`, `bat`, GIMP, VLC, Thunderbird, Filezilla, nmap, fuentes MS, etc. Purga juegos GNOME y Apache2.
- **PHP** y **Composer**.
- **Node.js 23** (repositorio NodeSource).
- **Docker CE** (creando antes el grupo `docker` con GID 600 para alinear con LDAP).
- **MongoDB Compass** y **Cisco Packet Tracer 8.2.2** (descargados por `scp` del FTP interno; Packet Tracer incluye las dependencias `libappindicator1`/`libdbusmenu` para 24.04 y aceptación de EULA no interactiva).
- **Google Chrome**.
- **VirtualBox 7.1** (solo si Secure Boot está desactivado).
- **Driver NVIDIA 570** (solo si detecta GPU NVIDIA — dotación de equipos nuevos 2026).
- **Snaps:** Firefox, Eclipse, Sublime Text, Android Studio, IntelliJ IDEA, MySQL Workbench, DBeaver, Postman, drawio, VS Code, PowerShell, lsd, tldr, Shotcut. (El proxy de Snap está actualmente deshabilitado: `snap unset core proxy.store`.)

### `containers` — Bases de datos en Docker

- Instala `daemon.json` declarando el registro inseguro `proxy-docker.tierno.es:5000`.
- Crea (sin arrancar) contenedores de BBDD por turno, tirando de imágenes del registro interno:
  - MySQL 8.1 (`mysql_native_password`): `diurno-mysql`, `vespertino-mysql`.
  - PostgreSQL 14: `diurno-postgres`, `vespertino-postgres`.
  - MongoDB 8.0.3: `diurno-mongo`, `vespertino-mongo`.

### `veyon` — Control de aula

- **Deshabilita Wayland** en GDM (`WaylandEnable=false`) — imprescindible para que Veyon funcione (requiere Xorg/X11).
- Añade el PPA `veyon/stable` e instala `veyon`, importando `veyon-config-client.json`.
- **Acceso solo para profesores:** restringe los binarios y lanzadores de Veyon (`veyon-cli`, `veyon-master`, `veyon-configurator`) al grupo `PROFESORES_GID` (10000).
- Crea un *override* de systemd con `Restart=always` y dependencia de `network-online`.
- Instala la **clave pública del aula** correspondiente (`scripts/veyon/keys/<AULA>_public_key.pem`) según el hostname.
- **Watchdog** (`install_veyon_watchdog.sh`): instala un *healthcheck* (`veyon-cli service status` o sondeo del puerto 11100) y un *timer* systemd que cada 30 s reinicia Veyon si está caído, más *hooks* de reanudación tras suspensión y cambios de red.

### `inventory` — OCS Inventory

Instala el agente `ocsinventory-agent` (repositorio OCS para `noble`), lo configura contra `http://inventory.lan.tierno.es:8081/ocsinventory` y le asigna un **TAG** derivado del aula (p. ej. `b22-a1` → `B22`). Fuerza un primer inventario al terminar.

### `cron` — Tareas programadas

Instala el crontab:

```
00 22 * * *  /sbin/shutdown -h now          # Apagado automático a las 22:00
00 09 * * *  /usr/bin/ocsinventory-agent     # Inventario diario a las 09:00
```

### `wake-on-lan` — Encendido remoto

Activa Wake-on-LAN por dos vías para cubrir distintas configuraciones de red:

- `wol-networkd.sh`: crea `/etc/systemd/network/50-wakeonlan.link` con `WakeOnLan=magic` para la MAC del interfaz por defecto.
- `wol-netplan.sh`: recorre las conexiones Ethernet de NetworkManager y aplica `802-3-ethernet.wake-on-lan magic`.

Pensado para los equipos blancos del aula B27, que pierden el WOL en cada arranque.

### `ssh` — Acceso remoto

- Instala `openssh-server` (con reinstalación forzada, necesaria en Ubuntu 24).
- Despliega `authorized_keys` para `root` y `administrator`.
- Aplica `sshd_tierno.conf`: deshabilita login root por contraseña y la autenticación por contraseña **en general**, salvo desde la red interna `172.20.0.0/24`.
- Habilita el servicio y permite SSH en UFW por si estuviera activo.

---

## 7. Scripts de mantenimiento (raíz)

| Script | Función |
| --- | --- |
| `clean_users.sh` | Detiene SSSD, borra los *homes* de `diurno` y `vespertino`, limpia la caché y reinicializa ambos usuarios (primer login + visibilidad en GDM). Útil para "resetear" un equipo entre turnos/cursos. |
| `fix_administrator.sh` | Renombra a `administrator` el usuario con UID/GID 1000 cuando la instalación de Ubuntu creó un nombre erróneo. Debe ejecutarse antes que `install.sh`. |
| `fix_docker_group.sh` | Garantiza que el grupo `docker` tenga **GID 600** (alineado con LDAP); lo recrea si es necesario y reinicia. |

---

## 8. Convenciones y patrones de diseño

- **Idempotencia:** los módulos comprueban estado antes de actuar (`dpkg -l | grep`, `grep -q`, `command -v`), de modo que `install.sh` puede reejecutarse sin romper nada.
- **Patrón de módulo:** cada carpeta de `scripts/` tiene su `install.sh` y sus ficheros de configuración junto a él; el orquestador entra en la carpeta (`cd`) y ejecuta el script desde ahí.
- **`install(1)` para desplegar ficheros:** se usa `install -o root -g root -m <modo> ...` para copiar configuraciones con permisos explícitos.
- **Edición segura de ficheros del sistema:** vía `ensure_line_in_file` para no duplicar reglas en reejecuciones.
- **Salida con `die()`:** todos los scripts principales definen `die()` y validan ejecución como `root`.

---

## 9. Pendientes (`TODO.md`)

- Añadir Font Awesome; revisar `lsd`.
- Mejorar el *prompt* (posible `oh-my-zsh`).
- Extensiones de `ranger`.

Adicionalmente, el propio código sugiere migrar el módulo `auth` a Ansible por su fragilidad.

---

## 10. Mapa del repositorio

```
instalacion/
├── bootstrap.sh                 # Entrada interactiva (descarga + reinicia)
├── bootstrap-unattended.sh      # Entrada desatendida (-y, -h)
├── install.sh                   # Orquestador principal
├── install-nogui.sh             # Variante de respaldo sin Zenity
├── clean_users.sh               # Mantenimiento: reset de usuarios de turno
├── fix_administrator.sh         # Mantenimiento: renombrar usuario 1000
├── fix_docker_group.sh          # Mantenimiento: GID 600 de docker
├── LICENSE                      # GPL-3.0
├── README.md
├── TODO.md
└── scripts/
    ├── functions.sh             # Biblioteca común (ensure_line_in_file, GIDs)
    ├── hostname/                # Nombre del equipo + registro en servidor
    ├── apt/                     # APT + proxy de caché con autodetección
    ├── gnome-extensions/        # Extensión de info del host
    ├── certs/                   # CA raíz interna
    ├── local-users/             # Bloqueo de password local de administrator
    ├── ldap/                    # Cliente SSSD/LDAP
    ├── auth/                    # Restricción horaria (pam_time)
    ├── dhcp/                    # Cliente DHCP endurecido
    ├── bash/                    # .bashrc, .gitconfig, umask
    ├── resolve/                 # Dominio de búsqueda tierno.es
    ├── apps/                    # Software docente (APT/Snap/.deb)
    ├── containers/              # Docker + BBDD por turno
    ├── veyon/                   # Control de aula + watchdog + claves
    ├── inventory/               # Agente OCS Inventory
    ├── cron/                    # Tareas programadas
    ├── wake-on-lan/             # WOL (networkd + netplan)
    └── ssh/                     # Servidor SSH + claves
```