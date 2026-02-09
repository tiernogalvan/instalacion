#!/bin/bash
# IES Enrique Tierno Galvan
#
# Test the list of cache servers to return the first one alive as APT cache,
# or fallback to direct download.
# APT runs this expecting to return just one line, so we make an effort 
# not to return anything else.
#
# This is called from /etc/apt/apt.conf.d/01proxy.conf:
# Acquire::http::Proxy-Auto-Detect "/usr/bin/apt-proxy-detect.sh";
#
# servers=("172.20.0.21" "172.20.0.22")
servers=("172.20.0.21")
port=3142
timeout=3
retry=2
logfile='/var/log/apt/apt-proxy-detect.log'

log() {
  msg="[$(date "+%Y-%m-%d %H:%M:%S")] $@" 
  (echo "$msg" >> $logfile) &>/dev/null
}

server_reachable() {
  if timeout $timeout bash -c "</dev/tcp/${1}/${2}" &>/dev/null ; then
    true
  else
    log "Proxy down http://${1}:${2}"
    false
  fi
}

# In case we add multiple cache servers, uncomment this to shuffle them
# [[ $(which shuf) ]] && servers=( $(shuf -e "${servers[@]}") )

for ip in "${servers[@]}"; do
  for ((n=0; n < $retry; n++)); do
    if server_reachable $ip $port ; then
        printf "http://${ip}:${port}/"
        exit 0
    fi
  done
done

log "Fallback to direct apt download (no proxy)"
timeout $timeout wget -q https://lan.tierno.es/msg/apt-proxy-fallback-direct
printf "DIRECT"
