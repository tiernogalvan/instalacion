#!/bin/bash

echo '[tierno] El usuario no se puede loguear en esta franja horaria.'

user_time_line="$(grep $PAM_USER /etc/security/time.conf)"
if [[ $user_time_line ]]; then
  # Parse a line like '* ; * ; user ; Al1500-2200'
  last_part="$(echo $user_time_line | awk -F ';' '{print $NF}' | sed 's/ //g')"
  start_time="$(echo $last_part | sed -n -E 's/.*([0-9]{2})([0-9]{2})-.*/\1:\2/p')"
  end_time="$(echo $last_part | sed -n -E 's/.*-([0-9]{2})([0-9]{2})/\1:\2/p')"
  if [[ -n $start_time && -n $end_time ]]; then
    echo "[tierno] Horario posible para ${PAM_USER}: $start_time - $end_time"
  else
    echo "[tierno] Horario posible para ${PAM_USER}: $last_part"
  fi
fi

exit 0
