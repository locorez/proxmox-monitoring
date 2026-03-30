#!/bin/bash
set -euo pipefail

WEBHOOK_URL="http://192.168.2.11:5000/send-8f3aKlm92"
HOSTNAME="$(hostname)"

ERRORS=()

log() {
  echo "[SMART-LONG] $1"
}

log "Starting SMART long test on $HOSTNAME"

DISKS=($(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}'))

if [[ ${#DISKS[@]} -eq 0 ]]; then
  log "No disks found"
  exit 1
fi

for DISK in "${DISKS[@]}"; do
  log "Launching long test on $DISK"
  smartctl -t long "$DISK" > /dev/null 2>&1 || true
done

# Espera conservadora per discos grans
# 4 TB acostuma a ser diverses hores; 6 h és una base prudent
sleep 21600

for DISK in "${DISKS[@]}"; do
  HEALTH_OUTPUT="$(smartctl -H "$DISK" 2>/dev/null || true)"
  ATTR_OUTPUT="$(smartctl -A "$DISK" 2>/dev/null || true)"
  SELFTEST_OUTPUT="$(smartctl -l selftest "$DISK" 2>/dev/null || true)"

  STATUS="$(echo "$HEALTH_OUTPUT" | grep -E 'SMART overall-health|SMART Health Status' | awk -F: '{print $2}' | xargs || true)"
  REALLOC="$(echo "$ATTR_OUTPUT" | awk '/Reallocated_Sector_Ct/ {print $10}')"
  PENDING="$(echo "$ATTR_OUTPUT" | awk '/Current_Pending_Sector/ {print $10}')"
  UNCORR="$(echo "$ATTR_OUTPUT" | awk '/Offline_Uncorrectable/ {print $10}')"

  REALLOC="${REALLOC:-0}"
  PENDING="${PENDING:-0}"
  UNCORR="${UNCORR:-0}"

  LAST_TEST_LINE="$(echo "$SELFTEST_OUTPUT" | awk 'NF && $1=="#"{print; exit}')"
  TEST_FAILED=0

  if echo "$SELFTEST_OUTPUT" | grep -qiE 'Completed: read failure|Completed: unknown failure|Completed: electrical failure|Completed: servo/seek failure|Interrupted|Aborted by host'; then
    TEST_FAILED=1
  fi

  if [[ "${STATUS:-PASSED}" != "PASSED" || $REALLOC -gt 0 || $PENDING -gt 0 || $UNCORR -gt 0 || $TEST_FAILED -eq 1 ]]; then
    ERRORS+=("$DISK → health:${STATUS:-unknown} realloc:$REALLOC pending:$PENDING uncorr:$UNCORR selftest:${LAST_TEST_LINE:-no-result}")
  fi
done

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  MESSAGE="💥 SMART LONG WARNING on $HOSTNAME:\n\n$(printf "%s\n" "${ERRORS[@]}")"

  curl -sS --max-time 10 -X POST "$WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"title\": \"SMART Long Alert\",
      \"message\": \"$MESSAGE\"
    }" >/dev/null

  log "Alert sent"
else
  log "All disks OK after long test"
fi
