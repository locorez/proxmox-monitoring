# SMART Long Monthly Check

## 🎯 Objectiu

Executar un **SMART long test mensual** als discos del servidor Proxmox per detectar errors reals de lectura i fallades latents que no es veuen amb el short test.

Si es detecta qualsevol problema, s’envia una alerta a Telegram via webhook.

---

## 🧠 Funcionament

El sistema es divideix en **dues fases** (recomanat):

### 1️⃣ Execució del test

* Llança `smartctl -t long` a tots els discos
* El test s’executa en segon pla dins del disc

* Detecta:

  * errors de lectura
  * fallades internes
  * tests interromputs

---

## 📂 Ubicació

Scripts desplegats al servidor **Proxmox** a:

```bash id="r8gl6d"
/root/scripts/smart-long-check.sh
```

---

## ⚙️ Configuració

Variable principal:

```bash id="b7m92s"
WEBHOOK_URL="http://192.168.2.11:5000/send-8f3aKlm92"
```

---

## ⏱ Execució automàtica (cron)

Editar crontab:

```bash id="i4r9sm"
crontab -e
```

Afegir:

```cron id="q4tqz2"
# Llançar test long (1 cop al mes)
0 1 1 * * /root/scripts/smart-long-check.sh >> /var/log/smart-long.log 2>&1
```

---

## 🧾 Logging

Output redirigit a:

```bash id="jv88zx"
/var/log/smart-long.log
```

Gràcies a:

```cron id="hczc0k"
>> /var/log/smart-long.log 2>&1
```

---

## 🧪 Test manual

```bash id="lq5x0b"
bash /root/scripts/smart-long-check.sh
```

---

## ⚠️ Comportament

* Si tot està OK → no envia res
* Si hi ha error → envia alerta
* Basat en logs reals del disc

---

## 🔐 Seguretat

* Webhook només accessible via LAN
* No s’utilitzen secrets
* Control gestionat pel backend

---

## 🧠 Notes tècniques

* `smartctl -l selftest` és la font més fiable
* Els resultats queden persistits al disc
* Detecta fallades que el short test no veu

---

## 🔮 Millores futures

* Correlació amb mètriques SMART (`-A`)
* Integració amb ZFS errors
* Alertes només en canvis d’estat
* Dashboard centralitzat

---

## 🧩 Flux

```text id="o7z1y4"
SMART long test
        ↓
Disc executa test intern
        ↓
Webhook
        ↓
Telegram
```

---

## ✅ Estat

* ✔ Monitorització profunda SMART
* ✔ Execució mensual automatitzada
* ✔ Logging persistent
* ✔ Alertes en temps real
* ✔ Sistema robust i fiable

---
