#!/bin/bash
#
# Instalación de la plataforma de equipos
# del IES Enrique Tierno Galván
#

die() { echo "$*" 1>&2 ; exit 1; }

if [[ "$EUID" -ne 0 ]]; then
  die "Please run as root."
fi

# An array to hold all the step names.
declare -a STEPS
declare -a exit_codes=()


###########################################################
# Declaración de funciones
###########################################################

rootpath="$(pwd)"
install_step() {
  # Use absolute path in case some script changed directory
  cd ${rootpath}/scripts/$1
  bash ./install.sh
}

insert_step() {
  local step_name="$1"
  STEPS+=("$step_name")
}

run_install_steps_zenity() {
  local num_steps=${#STEPS[@]}
  [ "$num_steps" -eq 0 ] && return

  # Create a named pipe (FIFO) for stable communication with Zenity.
  # We will use file descriptor 3 to this pipe, leaving stdout (fd 1) for normal logging.
  # Trap SIGPIPE to allow closing the zenity window.
  local PIPE_NAME="/tmp/zenity_pipe_$$"
  mkfifo "$PIPE_NAME"
  trap 'rm -f "$PIPE_NAME"' EXIT
  trap '' SIGPIPE

  zenity --progress \
    --title="Instalación de plataforma" \
    --text="Iniciando..." \
    --percentage=0 \
    --width=450 \
    --auto-close \
    --auto-kill < "$PIPE_NAME" &

  disown
  exec 3>"$PIPE_NAME"

  local increment
  increment=$(bc -l <<< "100 / $num_steps")
  local progress=0

  for i in "${!STEPS[@]}"; do
    step_name="${STEPS[$i]}"

    if [[ $(pidof zenity) ]]; then
      echo "# Ejecutando paso $((i+1)) de $num_steps: $step_name" >&3
    fi

    install_step "$step_name"
    exit_codes+=($?)

    if [[ $(pidof zenity) ]]; then
      progress=$(bc -l <<< "$progress + $increment")
      echo "scale=0; $progress/1" | bc >&3
    fi
  done

  if [[ $(pidof zenity) ]]; then
    echo "100" >&3
  fi

  # Close the file descriptor 3.
  exec 3>&-
}

run_install_steps_console() {
    for i in "${!STEPS[@]}"; do
      install_step "$step_name"
      exit_codes+=($?)
    done
}

run_install_steps() {
  if [[ $(which zenity) ]]; then
    run_install_steps_zenity
  else
    run_install_steps_console
  fi
}

print_final_report() {
    echo -e "\n--- Installation Report ---"
    has_failures=0
    for i in "${!STEPS[@]}"; do
        if [ "${exit_codes[$i]}" -eq 0 ]; then
            # Using printf for better formatting and color.
            printf "\e[32m[ OK ]\e[0m %s\n" "${STEPS[$i]}"
        else
            printf "\e[31m[FAIL]\e[0m %s\n" "${STEPS[$i]}"
            has_failures=1
        fi
    done
    echo
    return $has_failures
}


###########################################################
# Fin de funciones
###########################################################


clear

echo
echo
echo "  _   _                                   _                  "
echo " | |_(_) ___ _ __ _ __   ___   __ _  __ _| |_   ____ _ _ __  "
echo " | __| |/ _ \ '__| '_ \ / _ \ / _\` |/ _\` | \ \ / / _\` | '_ \ "
echo " | |_| |  __/ |  | | | | (_) | (_| | (_| | |\ V / (_| | | | |"
echo "  \__|_|\___|_|  |_| |_|\___/ \__, |\__,_|_| \_/ \__,_|_| |_|"
echo "                              |___/                          "
echo
echo "IES Enrique Tierno Galván"
echo "Asistente de instalación de equipo."
echo


if [[ ${SUDO_USER} != "administrator" ]]; then
  echo "Este script debe ejecutarse con el usuario administrator (usuario actual $SUDO_USER)"
  echo "Si durante la instalación de Ubuntu se crea un usuario erróneo, sigue las instrucciones del punto Arreglar nombre del usuario administrator del README de este repositorio"
  exit -1
fi

install_step hostname  # Must be first
echo "Comenzando instalación..."
echo

insert_step apt
insert_step ssh
insert_step certs
insert_step gnome-extensions # Mejor antes de ldap
insert_step ldap
insert_step auth # Después de ldap
insert_step bash
insert_step resolve
insert_step apps
insert_step containers
insert_step veyon
insert_step cron
insert_step wake-on-lan

run_install_steps

apt install --fix-missing -y
apt autoremove -y
apt autoclean -y

print_final_report
[[ $? -ne 0 ]] && die "Hubo errores en la instalación."

if [[ $1 == "-s" ]]; then
  echo "Apagando..."
  shutdown -h now
elif [[ $1 == "-r" ]]; then
  echo "Reiniciando..."
  reboot
else 
  echo "Reinicia el sistema."
fi
