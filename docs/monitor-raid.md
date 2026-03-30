# ZFS RAID Monitor

## 🎯 Objectiu

Monitoritzar l’estat d’un pool ZFS (RAID) i enviar una alerta a Telegram si es detecta qualsevol problema (degradació, errors, discos fallant, etc.).

---

## 🧠 Funcionament

El script:

1. Executa `zpool status -x <pool>`
2. Analitza el resultat:

   * Si tot està OK → no fa res
   * Si hi ha algun problema → envia alerta
3. Envia notificació via webhook cap al sistema de Telegram

---

## 📂 Ubicació

El script està desplegat al servidor **Proxmox** a:

```bash
/root/scripts/monitor_raid.sh
```

---

## ⚙️ Configuració

Variables clau:

```bash
WEBHOOK_URL="http://192.168.2.11/send-8f3aKlm92"
ZPOOL_NAME="datazfs"
```

* **WEBHOOK_URL** → endpoint del teu sistema de notificacions
* **ZPOOL_NAME** → nom del pool ZFS (com `zpool list`)

---

## ⏱ Execució automàtica (cron)

Afegir al crontab de `root`:

```bash
crontab -e
```

Exemple (cada 5 minuts):

```cron
*/5 * * * * /root/scripts/monitor_raid.sh
```

---

## 🧪 Test manual

```bash
bash /root/scripts/monitor_raid.sh
```

---

## ⚠️ Comportament

* Si el pool està **healthy** → no envia res
* Si el pool està **degraded / faulty / errors** → envia alerta
* Cada execució amb error → nova alerta

---

## 🔐 Seguretat

* El webhook està en xarxa local (`192.168.x.x`)
* No s’utilitzen secrets
* Protecció delegada al servidor webhook

---

## 🧠 Notes tècniques

* `zpool status -x` retorna:

  * `"pool '<name>' is healthy"` si tot OK
  * informació detallada si hi ha errors
* El script compara exactament aquest valor

---

## 🔮 Millores futures

* Evitar alertes duplicades (state file intel·ligent)
* Incloure discs afectats al missatge
* Integració amb SMART (`smartctl`)
* Dashboard centralitzat de salut

---

## 🧩 Flux

```text
ZFS (zpool status)
        ↓
Script monitor_raid.sh
        ↓
Webhook local
        ↓
Telegram
```

---

## ✅ Estat

* ✔ Monitorització RAID activa
* ✔ Alertes automàtiques
* ✔ Execució via cron
* ✔ Sistema simple i fiable

---

