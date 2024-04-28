#!/bin/bash
# Pregunta el nombre de aula y de puesto del equipo.
# Establece el hostname.
# Envía los datos al servidor junto a la MAC del equipo.
#

read_aula() {
  aula=""
  while [[ ! $aula ]]; do
    # Forcing the read from tty allows this script to be run from a pipe
    read -p "Indica el aula (B15, B17, B21, B22...): " aula < /dev/tty
    [[ $aula ]] || continue
    aula=$(echo $aula | tr '[:lower:]' '[:upper:]')
    [[ $aula =~ ^[0-9][0-9]$ ]] && aula="B$aula"
    case $aula in
      B15|B17|B21|B22|B23|B24|B25|B27|B32) 
        ;;
      *)
        echo "El aula debería ser: B15, B17, B21, B22, B23, B24, B25, B27, B32" > /dev/tty
        read -p "¿Seguro que quieres usar ${aula}? (y/n): " confirm < /dev/tty
        if [[ $confirm != 'y' ]]; then
          aula=""
          echo > /dev/tty
        fi
        ;;
    esac
  done
  echo $aula
}

read_puesto() {
  puesto=""
  while [[ ! $puesto ]]; do
    read -p "Indica el puesto (A1, A2... F3, F4): " puesto < /dev/tty
    [[ $puesto ]] || continue
    puesto=$(echo $puesto | tr '[:lower:]' '[:upper:]')
    if [[ ! $puesto =~ ^[A-F][0-5]$ ]]; then
        read -p "Puesto no contemplado. ¿Seguro que quieres usar ${puesto}? (y/n): " confirm < /dev/tty
        if [[ $confirm != 'y' ]]; then
          puesto=""
          echo > /dev/tty
        fi
    fi
  done
  echo $puesto
}

hostname_is_ok() {
  [[ $(hostname | grep -E '^B[0-9]{2}-[A-F][0-5]$') ]] && echo $(hostname)
}

set_hostname=true
if [[ $(hostname_is_ok) ]]; then
  echo "Equipo detectado."
  echo "  Aula: $(hostname | cut -d'-' -f1)"
  echo "  Puesto: $(hostname | cut -d'-' -f2)"
  read -p "¿Es correcto? (y/n): " correcto
  [[ $correcto = 'y' ]] && unset set_hostname
fi

if [[ $set_hostname ]]; then
  aula=$(read_aula)
  puesto=$(read_puesto)
  hostname="${aula}-${puesto}"
  echo "Setting hostname $hostname"
  hostnamectl hostname $hostname
fi


# Send the mac address
devs=$(ip route show default | awk '/default via [0-9\.]* dev/ {print $5}')
for dev in $devs ; do
  mac=$(cat /sys/class/net/${dev}/address)
  wget -q -O /dev/null "https://lan.tiernogalvan.es/hostname/${hostname}/${mac}"
done
