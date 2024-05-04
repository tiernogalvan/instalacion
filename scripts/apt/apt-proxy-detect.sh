#!/bin/bash
#
# This is called from /etc/apt/apt.conf.d/01proxy-fallback.conf:
# Acquire::http::Proxy-Auto-Detect "/usr/bin/apt-proxy-detect.sh";
#
cache_servers=("172.20.0.21" "172.20.0.22")
port=3142

# Method 1 requires netcat installed
# [[ $(nc -w1 -z $ip $port &>/dev/null; echo $?) -eq 0 ]]
#
# Method 2 using linux:
# (echo > /dev/tcp/skinner/22) >/dev/null 2>&1 && echo "It's up" || echo "It's down"
server_reachable() {
 # (echo > /dev/tcp/$1/$2) >/dev/null 2>&1 && true || false
 if (echo > /dev/tcp/${1}/${2}) >/dev/null 2>&1 ; then
   true
 else
   false
 fi
}

for ip in "${cache_servers[@]}"; do
  if server_reachable $ip $port ; then
      echo -n "http://${ip}:${port}/"
      exit 0
  fi
done

# Fallback to direct download
echo -n "DIRECT"
