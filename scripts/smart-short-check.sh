#!/bin/bash
set -euo pipefail

WEBHOOK_URL="http://192.168.2.11:5000/send-8f3aKlm92"
HOSTNAME=$(hostname)

ERRORS=()

DISKS=($(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}'))

for DISK in "${DISKS[@]}"; do
  smartctl -t short "$DISK" > /dev/null 2>&1 || true
done

sleep 180

for DISK in "${DISKS[@]}"; do
  OUTPUT=$(smartctl -A "$DISK" 2>/dev/null || true)

  REALLOC=$(echo "$OUTPUT" | awk '/Reallocated_Sector_Ct/ {print $10}')
  PENDING=$(echo "$OUTPUT" | awk '/Current_Pending_Sector/ {print $10}')
  UNCORR=$(echo "$OUTPUT" | awk '/Offline_Uncorrectable/ {print $10}')

  REALLOC=${REALLOC:-0}
  PENDING=${PENDING:-0}
  UNCORR=${UNCORR:-0}

  if (( REALLOC > 0 || PENDING > 0 || UNCORR > 0 )); then
    ERRORS+=("$DISK → realloc:$REALLOC pending:$PENDING uncorr:$UNCORR")
  fi
done

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  MESSAGE="💥 SMART WARNING on $HOSTNAME:\n\n$(printf "%s\n" "${ERRORS[@]}")"

  curl -sS --max-time 10 -X POST "$WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"title\": \"SMART Alert\",
      \"message\": \"$MESSAGE\"
    }" >/dev/null
fi
