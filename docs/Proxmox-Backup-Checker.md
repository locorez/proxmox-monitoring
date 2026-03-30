# ProxmoxBackupChecker

## 🎯 Objectiu

Detectar si els backups de Proxmox han fallat i enviar una alerta automàtica a Telegram mitjançant un webhook.

---

## 🧠 Funcionament

El script:

1. Llegeix els logs de Proxmox del dia actual (`journalctl`)
2. Filtra les entrades relacionades amb `vzdump` (backups)
3. Comprova si hi ha algun `TASK ERROR`
4. Si detecta error:

   * envia una notificació via webhook
5. Si no hi ha errors:

   * no fa res

👉 No guarda estat → si hi ha error, avisarà cada vegada que s’executi

---

## 📂 Ubicació

Script desplegat al servidor Proxmox:

```bash
/root/scripts/Proxmox-Backup-Checker.sh
```

---

## ⏱ Execució automàtica (cron)

Afegir al crontab de `root`:

```bash
crontab -e
```

Entrada:

```cron
0 4 * * 6 /root/scripts/Proxmox-Backup-Check.sh
```

### 📌 Significat

```text
0 4 * * 6
│ │ │ │ │
│ │ │ │ └── dissabte
│ │ │ └──── cada mes
│ │ └────── cada dia
│ └──────── 04:00
└────────── minut 0
```

👉 S’executa **cada dissabte a les 04:00**, després del backup programat (02:00)

---

## 🧪 Test manual

```bash
bash /root/scripts/Proxmox-Backup-Check.sh
```

---

## 🔐 Seguretat

* El webhook només és accessible des de xarxa local (LAN)
* No s’utilitzen secrets en el script
* Protecció delegada al backend (Flask)

---

## ⚠️ Comportament

* Si el backup falla → envia alerta
* Si el backup continua fallant → enviarà alerta cada execució
* Si tot funciona → no envia res

---

## 🔮 Millores futures

* Incloure VMID afectades
* Resum complet OK / FAIL
* Logs estructurats

---

## 🧩 Flux complet

```text
Proxmox Backup (vzdump)
        ↓
Logs (journalctl)
        ↓
Script checker (cron)
        ↓
Webhook Flask
        ↓
Telegram
```

---

## ✅ Estat

* ✔ Monitorització de backups activa
* ✔ Alertes automàtiques
* ✔ Execució programada
* ✔ Sistema simple i robust

---

