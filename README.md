# 🖥️ Proxmox Monitoring Suite

Sistema lleuger de monitorització per entorns Proxmox amb alertes en temps real via Telegram.

---

## 🎯 Objectiu

Detectar problemes abans que siguin crítics:

* ❌ Backups fallits
* ⚠️ RAID degradat (ZFS)
* 💥 Discs en degradació (SMART)

---

## 🧱 Arquitectura

```text
Proxmox Host
    ↓
Scripts (cron)
    ↓
Webhook local (Flask)
    ↓
Telegram
```

---

## 📂 Estructura

```text
proxmox-monitoring/
├── README.md
├── scripts/
│   ├── Proxmox-Backup-Check.sh
│   ├── monitor_raid.sh
│   ├── smart-short-check.sh
│   └── smart-long-check.sh
├── docs/
│   ├── backup-checker.md
│   ├── raid-monitor.md
│   ├── smart-short.md
│   └── smart-long.md
├── cron/
│   └── crontab.example
```

---

## ⚙️ Components

### 🔹 Backup Checker

Detecta errors en backups (`vzdump`) via `journalctl`.

---

### 🔹 RAID Monitor (ZFS)

Controla l’estat del pool (`zpool status`) i detecta degradació.

---

### 🔹 SMART Short (diari)

Test ràpid (~3 min) per detectar degradació precoç.

Analitza:

* Reallocated sectors
* Pending sectors
* Uncorrectable errors

---

### 🔹 SMART Long (checker mensual)

⚠️ **Important: aquest script NO llança el test**

Només:

* consulta els resultats amb:

  ```bash
  smartctl -l selftest
  ```
* detecta:

  * errors de lectura
  * fallades internes
  * tests fallits o interromputs

👉 El test long ha de ser llançat per:

* `smartd`
* execució manual
* o altra automatització externa

---

## ⏱ Cron

```cron
# SMART short (diari)
0 3 * * * /root/scripts/smart-short-check.sh >> /var/log/smart-check.log 2>&1

# SMART long checker (mensual)
0 7 1 * * /root/scripts/smart-long-check.sh >> /var/log/smart-long.log 2>&1

# Backup checker (setmanal)
0 4 * * 6 /root/scripts/Proxmox-Backup-Check.sh >> /var/log/backup-check.log 2>&1

# RAID monitor (cada 5 min)
*/5 * * * * /root/scripts/monitor_raid.sh >> /var/log/raid.log 2>&1
```

---

## 🔔 Alertes

Webhook local:

```text
http://<ip-local>:5000/send-8f3aKlm92
```

---

## 📊 Logging

Logs a:

```text
/var/log/*.log
```

via:

```bash
>> /var/log/script.log 2>&1
```

---

## 🚀 Instal·lació

```bash
git clone git@github.com:locorez/proxmox-monitoring.git /root/scripts
chmod +x /root/scripts/*.sh
crontab -e
```

---

## ⚠️ Notes clau

### RAID ≠ Backup

El backup és el que et salva.

---

### SMART PASSED ≠ disc sa

El sistema detecta degradació real.

---

### SMART Long

* font més fiable de fallades
* basat en historial del disc
* no en estat instantani

---

## 🔮 Roadmap

* integrar `smartd`
* correlació SMART + ZFS
* alertes intel·ligents (no spam)
* dashboard centralitzat

---

## 🧩 Filosofia

* simple > complex
* Bash > frameworks
* útil > bonic

---

## ✅ Estat

* ✔ En producció
* ✔ Alertes en temps real
* ✔ Baix consum
* ✔ Fàcil manteniment

---
