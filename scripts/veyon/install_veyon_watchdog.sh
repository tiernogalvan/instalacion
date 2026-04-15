#!/usr/bin/env bash
set -euo pipefail

UNIT=veyon.service
PORT=${PORT:-11100}

# --- 1) Habilitar wait-online si aplica ---
for svc in NetworkManager-wait-online.service systemd-networkd-wait-online.service; do
  state=$(systemctl is-enabled "$svc" 2>/dev/null || true)
  if [[ -n "$state" && "$state" != "masked" ]]; then
    systemctl enable "$svc" >/dev/null 2>&1 || true
    break
  fi
done

# --- 2) Healthcheck script ---
install -d -m 0755 /usr/local/sbin
cat >/usr/local/sbin/veyon-healthcheck <<'EOSH'
#!/usr/bin/env bash
set -euo pipefail
UNIT="veyon.service"
PORT="${PORT:-11100}"

if command -v veyon-cli >/dev/null 2>&1; then
  if veyon-cli service status >/dev/null 2>&1; then
    exit 0
  fi
fi

if command -v nc >/dev/null 2>&1; then
  timeout 2s nc -z 127.0.0.1 "$PORT" 2>/dev/null && exit 0
elif command -v ss >/dev/null 2>&1; then
  ss -ltn "sport = :$PORT" 2>/dev/null | grep -q ":$PORT" && exit 0
fi

echo "[veyon-healthcheck] Unhealthy, restarting $UNIT" | systemd-cat -t veyon-healthcheck -p warning
exec systemctl restart "$UNIT"
EOSH
chmod +x /usr/local/sbin/veyon-healthcheck

# --- 3) Timer del watchdog cada 30s ---
cat >/etc/systemd/system/veyon-watchdog.service <<'EOF'
[Unit]
Description=Veyon availability watchdog

[Service]
Type=oneshot
Environment=PORT=11100
ExecStart=/usr/local/sbin/veyon-healthcheck
EOF

cat >/etc/systemd/system/veyon-watchdog.timer <<'EOF'
[Unit]
Description=Run Veyon watchdog periodically

[Timer]
OnBootSec=2min
OnUnitActiveSec=30s
AccuracySec=5s
Unit=veyon-watchdog.service

[Install]
WantedBy=timers.target
EOF

# --- 4) Hooks de resume y cambio de red ---
cat >/lib/systemd/system-sleep/veyon-restart <<'EOF'
#!/bin/sh
case "$1" in
  post) /usr/bin/systemctl try-restart veyon.service ;;
esac
EOF
chmod +x /lib/systemd/system-sleep/veyon-restart || true

if [ -d /etc/NetworkManager/dispatcher.d ]; then
  cat >/etc/NetworkManager/dispatcher.d/99-veyon-restart <<'EOF'
#!/bin/sh
IFACE="$1"; STATUS="$2"
case "$STATUS" in
  up|dhcp4-change|connectivity-change)
    /usr/bin/systemctl try-restart veyon.service
    ;;
esac
EOF
  chmod +x /etc/NetworkManager/dispatcher.d/99-veyon-restart
fi

# --- 5) Aplicar y arrancar ---
systemctl daemon-reload
systemctl enable --now "$UNIT" >/dev/null 2>&1
systemctl try-restart "$UNIT"
systemctl enable --now veyon-watchdog.timer

echo "✅ Veyon watchdog installed."