# SMART Short Daily Check

## 🎯 Objectiu

Executar un **SMART short test diari** als discos del servidor Proxmox per detectar signes de degradació abans que es produeixi una fallada.

Si es detecta qualsevol anomalia, s’envia una alerta a Telegram mitjançant un webhook.

---

## 🧠 Funcionament

El script:

1. Detecta automàticament tots els discos del sistema
2. Llança un **SMART short test** en paral·lel
3. Espera que els tests finalitzin (~3 minuts)
4. Analitza mètriques SMART crítiques:

   * `Reallocated_Sector_Ct`
   * `Current_Pending_Sector`
   * `Offline_Uncorrectable`
5. Si detecta valors anormals → envia alerta
6. Si tot està OK → no envia res

---

## 📂 Ubicació

Script desplegat al servidor **Proxmox** a:

```bash
/root/scripts/smart-short-check.sh
```

---

## ⚙️ Configuració

Variable principal:

```bash
WEBHOOK_URL="http://192.168.2.11:5000/send-8f3aKlm92"
```

👉 Endpoint del sistema de notificacions (Telegram webhook)

---

## ⏱ Execució automàtica (cron)

Editar crontab de `root`:

```bash
crontab -e
```

Afegir:

```cron
0 3 * * * /root/scripts/smart-short-check.sh >> /var/log/smart-check.log 2>&1
```

---

## 📌 Explicació del cron

```text
0 3 * * *
│ │ │ │ │
│ │ │ │ └── cada dia
│ │ │ └──── cada mes
│ │ └────── cada dia
│ └──────── 03:00
└────────── minut 0
```

👉 S’executa **cada dia a les 03:00**

---

## 🧾 Logging

L’output del script es redirigeix a:

```bash
/var/log/smart-check.log
```

Gràcies a:

```cron
>> /var/log/smart-check.log 2>&1
```

### 🧠 Què implica

* ✔ Es guarda l’historial d’execucions
* ✔ Permet diagnòstic posterior
* ✔ No es perd output com amb cron per defecte

---

## 🧪 Test manual

```bash
bash /root/scripts/smart-short-check.sh
```

---

## ⚠️ Comportament

* Si tots els discos estan bé → no envia res
* Si detecta degradació → envia alerta
* Cada execució amb error → nova alerta

---

## 🔐 Seguretat

* Webhook accessible només via LAN
* No s’utilitzen secrets al script
* Control d’accés gestionat pel backend

---

## 🧠 Notes tècniques

* `smartctl -H` no és fiable per detectar degradació
* Aquest script analitza mètriques internes SMART
* Permet detectar discs que estan **començant a fallar**

---

## 🔮 Millores futures

* Integració amb SMART long test
* Correlació amb errors ZFS
* Evitar alertes duplicades
* Dashboard centralitzat

---

## 🧩 Flux

```text
SMART test (discs)
        ↓
Script smart-short-check.sh
        ↓
Log local (/var/log)
        ↓
Webhook
        ↓
Telegram
```

---

## ✅ Estat

* ✔ Monitorització SMART activa
* ✔ Execució diària automatitzada
* ✔ Logging persistent
* ✔ Alertes en temps real
* ✔ Sistema simple i robust

---
