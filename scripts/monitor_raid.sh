#!/bin/bash
# ZFS RAID Monitoring Script - Sends alert to Telegram Monitoring Webhook

# 🔹 Configuració
WEBHOOK_URL="http://192.168.2.11/send-8f3aKlm92"
ZPOOL_NAME="datazfs"
ZFS_STATUS_FILE="/tmp/zfs_status"

# 🔹 Comprovar l'estat del ZFS pool
ZPOOL_STATUS=$(zpool status -x $ZPOOL_NAME)

if [[ "$ZPOOL_STATUS" != "pool 'datazfs' is healthy" ]]; then
    STATUS="⚠️ ALERTA: RAID DEGRADED ⚠️\n\n$ZPOOL_STATUS"

    curl -sS -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"title\": \"RAID ALERT\",
            \"message\": \"$STATUS\"
        }"
else
    echo "ZFS correcte"
    echo "OK" > $ZFS_STATUS_FILE
fi
