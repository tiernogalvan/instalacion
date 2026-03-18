#!/bin/bash
# Pregunta el nombre de aula y de puesto del equipo.
# Establece el hostname.
# Envía los datos al servidor junto a la MAC del equipo.
#
###########################################################
# Parseo de argumentos
###########################################################
AUTO_YES="${AUTO_YES:-0}"
HOSTNAME_PARAM=""

while getopts "yh:" opt; do
  case "$opt" in
    y) AUTO_YES=1 ;;
    h) HOSTNAME_PARAM="$OPTARG" ;;
  esac
done

# Sets variable aula
read_aula() {
  aula=""
  while [[ ! $aula ]]; do
    read -p "Indica el aula (B15, B17, B21, B22...): " aula 
    [[ $aula ]] || continue
    aula=$(echo $aula | tr '[:lower:]' '[:upper:]')
    [[ $aula =~ ^[0-9][0-9]$ ]] && aula="B$aula"
    case $aula in
      B15|B17|B21|B22|B23|B24|B25|B27|B32) 
        ;;
      *)
        read -p "Aula no reconocida. ¿Seguro que quieres usar ${aula}? (y/n): " confirm 
        if [[ $confirm != 'y' ]]; then
          aula=""
          echo > /dev/tty
        fi
        ;;
    esac
  done
}

# Sets variable puesto
read_puesto() {
  puesto=""
  while [[ ! $puesto ]]; do
    read -p "Indica el puesto (A1, A2... G4, G5, PROFESOR): " puesto 
    [[ $puesto ]] || continue
    puesto=$(echo $puesto | tr '[:lower:]' '[:upper:]' | tr ' .' '__')
    if [[ ! $puesto =~ ^(([A-J][0-7])|(PROFESOR))$ ]]; then
        read -p "Puesto no reconocido. ¿Seguro que quieres usar ${puesto}? (y/n): " confirm 
        if [[ $confirm != 'y' ]]; then
          puesto=""
          echo
        fi
    fi
  done
}

# Sets variable confirmed
confirm_puesto() {
  name="$1"
  aula=$(echo $name | cut -d- -f1)
  puesto=$(echo $name | cut -d- -f2)
  correcto=''
  while [[ ! $correcto ]]; do
    echo "Nombre de equipo detectado $name"
    echo "  Aula:   $aula"
    echo "  Puesto: $puesto"
    read -p "¿Es correcto? (y/n): " correcto
    [[ $correcto = 'y' || $correcto = 's' ]] && confirmed='y'
  done
}

configure_host() {
  hostname="$1"
  echo "Setting hostname $hostname"
  hostnamectl hostname $hostname
  devs=$(ip route show default | awk '/default via [0-9\.]* dev/ {print $5}' | sort | uniq)
  for dev in $devs ; do
    mac=$(cat /sys/class/net/${dev}/address)
    url="https://tierno.es/hostname/${hostname}/${mac}"
    echo "Sending $url"
    wget -q -O /dev/null "$url"
  done
}

# Si se pasó -h, establecer hostname directamente sin preguntar
if [[ -n "$HOSTNAME_PARAM" ]]; then
  echo "Hostname recibido por parámetro: $HOSTNAME_PARAM"
  configure_host "$HOSTNAME_PARAM"
  exit 0
fi

# Array of possible names to check
possible_names=()
add_possible() {
  if [[ ! ${possible_names[@]} =~ $1 ]]; then
    possible_names+=($1)
  fi
}
add_possible "$(hostname)"

# Add all reverse lookups for the main IP address
main_ip=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}' | head -n1)
lookup_list=$(dig +short -x $main_ip)
for lookup in "${lookup_list[@]}"; do
  name=$(echo $lookup | cut -d. -f1)
  add_possible "$name"
done

# Check detected names
host_configured=0
for name in "${possible_names[@]}"; do
  if [[ $host_configured -eq 0 && $name =~ ^B[0-9][0-9]-(([A-G][0-5])|(PROFESOR))$ ]]; then
    if [[ "$AUTO_YES" -eq 1 ]]; then
      echo "Hostname válido detectado: $name. Omitiendo configure_host (-y)."
      host_configured=1
    else
      confirm_puesto "$name"
      if [[ $confirmed == 'y' ]]; then
        configure_host "$name"
        host_configured=1
      fi
    fi
  fi
done

# No se encontró un hostname válido: configure_host es obligatorio
if [[ $host_configured -eq 0 ]]; then
  echo
  if [[ "$AUTO_YES" -eq 1 ]]; then
    echo "AVISO: No se detectó un hostname válido. Se requiere configuración manual aunque se haya pasado -y."
  fi
  echo "Configuración manual:"
  read_aula
  read_puesto
  host="${aula}-${puesto}"
  configure_host "$host"
fi