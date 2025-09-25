#!/usr/bin/env bash
set -euo pipefail

UNIT=veyon.service
PORT=${PORT:-11100}   # change if you customized Veyon port

# --- 1) Harden the main unit (override) ---
dropin="/etc/systemd/system/${UNIT}.d"
install -d -m 0755 "$dropin"
cat >"$dropin/override.conf" <<'EOF'
[Unit]
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
# Keep recovering if it ever drops
Restart=always
RestartSec=3s

# Avoid start bursts being rate-limited during flaky networks
StartLimitIntervalSec=0
EOF

# Try to ensure "network-online" actually triggers
if systemctl list-unit-files | grep -q '^NetworkManager-wait-online.service'; then
  systemctl enable NetworkManager-wait-online.service >/dev/null
elif systemctl list-unit-files | grep -q '^systemd-networkd-wait-online.service'; then
  systemctl enable systemd-networkd-wait-online.service >/dev/null
fi

# --- 2) Healthcheck script (use veyon-cli if present; fallback to TCP check) ---
install -d -m 0755 /usr/local/sbin
cat >/usr/local/sbin/veyon-healthcheck <<'EOSH'
#!/usr/bin/env bash
set -euo pipefail

UNIT="veyon.service"
PORT="${PORT:-11100}"

# Prefer native CLI if available
if command -v veyon-cli >/dev/null 2>&1; then
  if veyon-cli service status >/dev/null 2>&1; then
    exit 0
  fi
fi

# Fallback: local TCP probe
if command -v timeout >/dev/null 2>&1; then TO=timeout; else TO=""; fi
if command -v nc >/dev/null 2>&1; then
  ${TO:+$TO 2}s nc -z 127.0.0.1 "$PORT" && exit 0
elif command -v ss >/dev/null 2>&1; then
  ss -ltn '( sport = :'$PORT' )' | grep -q ":$PORT" && exit 0
fi

# If we get here, assume unhealthy -> try restart
echo "[veyon-healthcheck] Unhealthy, restarting $UNIT" | systemd-cat -t veyon-healthcheck -p warning
exec systemctl restart "$UNIT"
EOSH
chmod +x /usr/local/sbin/veyon-healthcheck

# --- 3) systemd timer to run the healthcheck every 30s ---
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

# --- 4) Resume & network-change hooks (cheap insurance) ---
# Resume hook
cat >/lib/systemd/system-sleep/veyon-restart <<'EOF'
#!/bin/sh
case "$1" in
  post) /usr/bin/systemctl try-restart veyon.service ;;
esac
EOF
chmod +x /lib/systemd/system-sleep/veyon-restart || true

# NetworkManager dispatcher hook (only if NM exists)
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

# --- 5) Apply & start everything ---
systemctl daemon-reload
systemctl enable --now "$UNIT" >/dev/null
systemctl try-restart "$UNIT"
systemctl enable --now veyon-watchdog.timer

echo "✅ Veyon watchdog installed. Logs: journalctl -u veyon-watchdog.service -u veyon.service --since '1 hour ago'"
