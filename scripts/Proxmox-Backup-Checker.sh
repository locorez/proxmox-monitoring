#!/bin/bash
set -euo pipefail

WEBHOOK_URL="http://192.168.2.11/send-8f3aKlm92"

log() {
  echo "[CHECK] $1"
}

SINCE="$(date -d 'today 00:00' '+%Y-%m-%d %H:%M:%S')"

# Logs del dia relacionats amb vzdump
LOGS=$(journalctl --since "$SINCE" --no-pager | grep vzdump || true)

if [[ -z "$LOGS" ]]; then
  log "No vzdump activity today → exit"
  exit 0
fi

# Detectar error
if echo "$LOGS" | grep -q "TASK ERROR"; then

  LAST_ERROR=$(echo "$LOGS" | grep "TASK ERROR" | tail -1)

  log "Backup FAILED detected"

  curl -s --max-time 10 -X POST "$WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"title\": \"❌ Proxmox backup FAILED\",
      \"message\": \"$(echo "$LAST_ERROR" | sed 's/"/\\"/g')\"
    }" >/dev/null || log "Webhook failed"

else
  log "Backup OK"
fi
