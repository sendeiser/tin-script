# VPS SSH & Dropbear Connection Limiter (`vps-ssh-limiter`)

[![Bash](https://img.shields.io/badge/Language-Bash%205.0%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Platform-Debian%20%7C%20Ubuntu-orange.svg)](https://www.debian.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Systemd](https://img.shields.io/badge/Daemon-Systemd-lightgrey.svg)](https://systemd.io/)

Suite modular, segura y de alto rendimiento diseñada para la administración integral de usuarios SSH y Dropbear en servidores **Debian** y **Ubuntu**, con panel de control interactivo CLI (estilo **Darnyx Script** y **ChumoGH**), control estricto de concurrencia, límites simultáneos por cuenta y **actualizador automático en un clic**.

Diseñado siguiendo estándares DevOps para entornos de producción, túneles seguros y reenvío de tráfico (port forwarding), garantizando un consumo de CPU inferior al 1% y cero dependencias de bases de datos externas.

---

## 📑 Tabla de Contenidos

- [Panel Interactivo Principal (menu / tin / vps)](#-panel-interactivo-principal-menu--tin--vps)
- [Guía y Conexión en HTTP Custom (Android / iOS)](#-guía-y-conexión-en-http-custom-android--ios)
- [Actualizador Automático en el Menú](#-actualizador-automático-en-el-menú)
- [Arquitectura y Principios de Diseño](#-arquitectura-y-principios-de-diseño)
- [Instalación](#-instalación)
  - [Instalación Rápida (Un Solo Comando)](#instalación-rápida-un-solo-comando)
  - [Instalación Manual](#instalación-manual)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Referencia de Comandos CLI](#-referencia-de-comandos-cli)
  - [menu / tin / vps](#menu--tin--vps)
  - [update / ssh-update](#update--ssh-update)
  - [ssh-useradd](#ssh-useradd)
  - [ssh-usermod](#ssh-usermod)
  - [ssh-userlock](#ssh-userlock)
  - [ssh-killuser](#ssh-killuser)
  - [ssh-userdel](#ssh-userdel)
  - [ssh-online](#ssh-online)
  - [ssh-httpcustom / httpcustom](#ssh-httpcustom--httpcustom)
  - [ssh-limiter (Demonio)](#ssh-limiter-demonio)
- [Supervisión con Systemd](#-supervisión-con-systemd)
- [Configuración de Red y Dropbear](#-configuración-de-red-y-dropbear)
- [Rendimiento y Consumo de Recursos](#-rendimiento-y-consumo-de-recursos)
- [Desinstalación](#-desinstalación)
- [Licencia](#-licencia)

---

## 🖥 Panel Interactivo Principal (`menu` / `tin` / `vps`)

Para abrir el panel de control interactivo en pantalla completa, simplemente ejecuta en tu terminal:

```bash
sudo menu
```
*(También puedes usar los atajos `sudo tin` o `sudo vps`)*

### Vista Previa del Dashboard:
```text
╔══════════════════════════════════════════════════════════════════════════════╗
║        VPS-SSH-LIMITER :: PANEL DE CONTROL Y ADMINISTRACIÓN          ║
╚══════════════════════════════════════════════════════════════════════════════╝
 S.O.: Ubuntu 22.04 LTS (x86_64)     IP Pública: 198.51.100.24
 Uptime: 14d 6h 32m                  Disco /: 5.8G/25G (24%)
 RAM: [████░░░░░░] 480MB / 2048MB (23%)    CPU: 1.2%
 Versión: [v1.4.0 - ACTUALIZADO]
──────────────────────────────────────────────────────────────────────────────
 SERVICIOS:  OpenSSH: [ONLINE]   Dropbear: [ONLINE]   Limitador: [ONLINE]
 CUENTAS:    Total: 12     |  Online: 5     |  Expiradas: 1
══════════════════════════════════════════════════════════════════════════════
 [1] ► GESTIÓN DE USUARIOS    (Crear, Renovar, Modificar, Bloquear, Eliminar)
 [2] ► MONITOR DE CONEXIONES  (Tabla en vivo, Modo dinámico en tiempo real)
 [3] ► DEMONIO LIMITADOR      (Estado, Reiniciar, Logs en vivo, Configuración)
 [4] ► PROTOCOLOS Y PUERTOS   (Puertos Dropbear, Reiniciar SSH/Dropbear)
 [5] ► OPTIMIZACIÓN Y SISTEMA (Limpiar RAM/Swap, Acelerador TCP BBR, Info)
 [6] ► GUÍA & DATOS HTTP CUSTOM (Tutorial paso a paso, Payloads y Fichas)
 [7] ► ACTUALIZAR SCRIPT      (Buscar e instalar actualizaciones desde GitHub)
 [8] ► DESINSTALAR SCRIPT     (Eliminar servicios y binarios del VPS)
 [0] ► SALIR
══════════════════════════════════════════════════════════════════════════════
```

---

## 📱 Guía y Conexión en HTTP Custom (Android / iOS)

La suite incluye un módulo dedicado para conectar clientes en la app **HTTP Custom** (y apps similares como HTTP Injector o eProxy) utilizando las cuentas túnel de tu VPS.

### 1. Formato Rápido de Importación (1-Click)
En HTTP Custom puedes copiar y pegar la cadena directa en el campo de conexión:
```text
IP_VPS:PUERTO@USUARIO:CONTRASEÑA
```
*Ejemplo:* `198.51.100.24:143@juan:clave123`

### 2. Configuración Manual Paso a Paso:
1. Abre **HTTP Custom** en tu dispositivo.
2. Marca la casilla **✔ SSH** en la pantalla principal.
3. Abre el menú lateral `(☰)` en la esquina superior izquierda y pulsa **SSH Setting**.
4. Rellena los datos de tu VPS:
   - **Server IP / Host:** La IP de tu servidor VPS.
   - **Server Port:** `143`, `90` o `109` (Dropbear) o `22` (OpenSSH).
   - **Username:** Nombre de usuario creado.
   - **Password:** Contraseña del usuario.
5. Regresa y pulsa **CONNECT**. En la pestaña **LOG** verás: `HTTP Custom: Connected`.

### 3. Ficha Automática para Enviar a Clientes (WhatsApp / Telegram)
Al crear cualquier cuenta desde el menú o con `ssh-useradd`, se genera automáticamente una ficha lista para copiar:
```text
🚀 *DATOS DE TU CUENTA SSH / HTTP CUSTOM*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 *Host / IP:* 198.51.100.24
🚪 *Puertos Dropbear:* 143, 90, 109 (Recomendados)
🚪 *Puerto OpenSSH:* 22
👤 *Usuario:* juan
🔑 *Contraseña:* clave123
📅 *Vencimiento:* 2026-10-12 (30 días)
📱 *Límite de Conexiones:* 2 dispositivo(s)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ *Formato Rápido de Importación en HTTP Custom:*
198.51.100.24:143@juan:clave123
```

### 4. Recomendaciones Anti-Desconexiones:
- **Activar Auto-Ping:** En el menú lateral de HTTP Custom, activa **Auto Ping** con un intervalo de **3 a 5 segundos** para mantener el socket SSH siempre activo.
- **Batería sin restricciones:** En Android -> Ajustes -> Aplicaciones -> HTTP Custom -> Batería -> "Sin restricciones" para evitar que el sistema cierre la app en segundo plano.
- **Respetar el límite simultáneo:** Si el cliente supera el límite asignado (por ejemplo, 2 conexiones), el demonio `ssh-limiter` cerrará de inmediato la conexión excedente más reciente.

---

## 🔄 Actualizador Automático en el Menú

El sistema cuenta con **detección inteligente de versiones**:
1. Cada vez que abres el menú, consulta en segundo plano la última versión disponible en GitHub.
2. Si detecta una nueva actualización, la opción **`[7] ► ACTUALIZAR SCRIPT`** se resalta automáticamente con una alerta visual:
   ```text
   [7] ► ACTUALIZAR SCRIPT ★ ¡NUEVA ACTUALIZACIÓN vX.Y.Z DISPONIBLE! ★
   ```
3. Al presionar **`7`**, el actualizador:
   - Descarga los archivos y micro-scripts nuevos.
   - Preserva todas las cuentas y contraseñas de tus usuarios.
   - Reinicia los servicios correspondientes.
   - Recarga el menú automáticamente en pantalla sin que tengas que salir.

También puedes actualizar directamente desde la terminal con el comando:
```bash
sudo update
# o también:
sudo ssh-update
```

---

## 🏛 Arquitectura y Principios de Diseño

### 1. Persistencia Atómica en GECOS
El límite de conexiones simultáneas se guarda de manera atómica directamente en el campo **GECOS** de `/etc/passwd` bajo el patrón `LIM:<N>` (por ejemplo, `LIM:2` para un máximo de 2 conexiones concurrentes).
- **Ventajas:** No requiere bases de datos (SQLite, MySQL o Redis) ni archivos planos volátiles que puedan quedar bloqueados o desincronizados ante cortes de energía imprevistos.
- **Tolerancia a fallos:** Compatible de forma nativa con herramientas del sistema (`useradd`, `usermod`, `passwd`).

### 2. Seguridad Estricta (Modo Túnel Nologin)
- Las cuentas creadas carecen de acceso a terminal interactiva (`/bin/false` o `/usr/sbin/nologin`).
- No se les crea directorio personal en el disco (`--no-create-home` y ruta `/nonexistent`).
- Se garantiza la inclusión de la shell restringida en `/etc/shells` para permitir la autenticación de red en Dropbear y OpenSSH sin conceder acceso al sistema operativo.

### 3. Inspección Directa de Procesos en `/proc` (Ultra Bajo Consumo)
A diferencia de scripts tradicionales que ejecutan costosos bucles de `netstat | grep | awk` consumiendo ciclos continuos de CPU:
- Utiliza llamadas compiladas en C (`pgrep -u`) que acceden directamente a las estructuras de `/proc`.
- **Detección dual nativa:**
  - **OpenSSH:** Sesiones autenticadas del usuario con `pgrep -u "$user" -f "^sshd: $user@"`.
  - **Dropbear:** Sesiones con privilegios cedidos al usuario mediante `pgrep -u "$user" -x "dropbear"`.
- Pausas pasivas inteligentes (`sleep 3`) que mantienen el uso de procesador por debajo del **0.2% - 0.5%**.

### 4. Mitigación Escalonada (Graceful Degradation)
Cuando un usuario excede su cuota configurada:
1. Se listan todos sus procesos activos y se ordenan de mayor a menor antigüedad utilizando su tiempo de vida (`ps -o pid=,etimes= --sort=-etimes`).
2. Se protegen y preservan las primeras **N** conexiones más antiguas (las sesiones originales del usuario).
3. Sobre las conexiones excedentes (las más recientes):
   - Se emite una señal **`SIGTERM` (15)** permitiendo un cierre ordenado de sockets.
   - Se aplica un período de gracia de 1.5 segundos.
   - Si el proceso no finalizó, se fuerza el cierre inmediato con **`SIGKILL` (9)**.
4. Si la cuenta ha superado su fecha límite de validez (expiración del sistema), se eliminan el 100% de sus conexiones activas de forma automática.

---

## 🚀 Instalación

### Instalación Rápida (Un Solo Comando)

En tu servidor Debian o Ubuntu, inicia como superusuario (`root`) y ejecuta:

```bash
sudo -i
curl -fsSL "https://raw.githubusercontent.com/sendeiser/tin-script/main/install.sh?v=$(date +%s)" | bash
```

### Instalación Manual

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/sendeiser/tin-script.git
   cd tin-script
   ```

2. **Otorgar permisos de ejecución:**
   ```bash
   chmod +x install.sh bin/*
   ```

3. **Ejecutar el instalador:**
   ```bash
   sudo ./install.sh
   ```

El instalador se encargará de:
- Instalar dependencias (`dropbear`, `procps`, `iproute2`, `coreutils`, `passwd`).
- Configurar Dropbear en los puertos **143**, **90** y **109** en `/etc/default/dropbear`.
- Registrar `/bin/false` y `/usr/sbin/nologin` en `/etc/shells`.
- Copiar los micro-scripts a `/usr/local/bin` y crear enlaces simbólicos en `/usr/bin`.
- Configurar los atajos globales `menu`, `update`, `tin` y `vps`.
- Instalar y activar el servicio `ssh-limiter.service` en systemd.

---

## 📂 Estructura del Proyecto

```
vps-ssh-limiter/
├── bin/
│   ├── menu                # Panel interactivo estilo Darnyx / ChumoGH (atajos: menu, tin, vps)
│   ├── ssh-update          # CLI: Actualizador automático desde GitHub (atajo: update)
│   ├── ssh-useradd         # CLI: Creación de usuarios con límite GECOS y expiración
│   ├── ssh-usermod         # CLI: Renovación de días, modificación de cuota y cambio de clave
│   ├── ssh-userlock        # CLI: Bloqueo/desbloqueo de cuentas con expulsión de sesiones
│   ├── ssh-killuser        # CLI: Desconexión forzosa de sesiones por usuario o masiva
│   ├── ssh-userdel         # CLI: Revocación forzosa y expulsión inmediata de procesos
│   ├── ssh-online          # CLI: Monitor en tiempo real con tabla formateada y JSON
│   └── ssh-limiter         # Demonio de monitoreo y mitigación escalonada
├── systemd/
│   └── ssh-limiter.service # Definición de unidad systemd para supervisión continua
├── install.sh              # Instalador y desinstalador automatizado desatendido
├── version                 # Archivo de control de versiones semver
├── LICENSE                 # Licencia MIT
└── README.md               # Documentación técnica completa
```

---

## 💻 Referencia de Comandos CLI

Todos los binarios se instalan en `/usr/local/bin/` y están vinculados en `/usr/bin/`, por lo que se encuentran disponibles globalmente en el `PATH` del sistema.

### `menu` / `tin` / `vps`

Abre el Panel de Control Interactivo en pantalla completa con telemetría en tiempo real:

```bash
sudo menu
```

---

### `update` / `ssh-update`

Verifica si hay una nueva versión disponible en GitHub, descarga las mejoras y actualiza el sistema automáticamente recargando el menú:

```bash
sudo update
```
*(O también `sudo ssh-update`)*

---

### `ssh-useradd`

Crea una cuenta segura para túneles con límite de conexiones y días de vigencia:

```bash
sudo ssh-useradd <usuario> <contraseña> <días_validez> <límite_conexiones>
```

#### Ejemplo:
```bash
sudo ssh-useradd juan MiClaveSegura2026 30 2
```

---

### `ssh-usermod`

Modifica los parámetros de una cuenta existente sin recrearla:

```bash
sudo ssh-usermod <usuario> [--days <+días>] [--limit <límite>] [--password <clave>]
```

#### Ejemplos:
```bash
# Renovar 30 días adicionales
sudo ssh-usermod juan --days 30

# Cambiar límite a 3 conexiones concurrentes
sudo ssh-usermod juan --limit 3

# Actualizar contraseña y añadir 15 días
sudo ssh-usermod juan --password nuevaClave99 --days 15
```

---

### `ssh-userlock`

Bloquea o desbloquea temporalmente el acceso de un usuario. Al bloquear, se desconectan todas sus sesiones activas:

```bash
sudo ssh-userlock <usuario> [lock|unlock|status]
```

---

### `ssh-killuser`

Desconecta inmediatamente todas las sesiones de un usuario sin borrar su cuenta, o realiza una mitigación masiva de conexiones excedentes:

```bash
# Desconectar un usuario específico
sudo ssh-killuser juan

# Desconectar todas las conexiones excedentes en el servidor
sudo ssh-killuser --all-exceeded
```

---

### `ssh-userdel`

Revoca la cuenta de un usuario expulsando de forma inmediata cualquier proceso o conexión activa antes de borrarlo:

```bash
sudo ssh-userdel <usuario>
```

---

### `ssh-online`

Muestra una tabla con el estado de todos los usuarios registrados, sus conexiones SSH y Dropbear en vivo, límites configurados y estado de expiración:

```bash
ssh-online
# O en formato JSON para bots y paneles web:
ssh-online --json
```

---

### `ssh-httpcustom` / `httpcustom`

Herramienta interactiva y generador de fichas de conexión para la aplicación HTTP Custom, con tutorial paso a paso y ejemplos de payloads:

```bash
# Abrir el asistente interactivo de HTTP Custom:
httpcustom
# O también:
custom
# O con el comando completo:
ssh-httpcustom

# Generar ficha rápida para un usuario específico:
ssh-httpcustom juan clave123

# Ver la guía paso a paso directamente en la consola:
ssh-httpcustom --guide

# Ver ejemplos de Payloads (WebSocket, CDN, Direct, Proxy):
ssh-httpcustom --payloads
```

---

### `ssh-limiter` (Demonio)

Es el servicio en segundo plano que vigila permanentemente los límites. Es administrado por `systemd`, pero puede ejecutarse directamente para depuración:

```bash
sudo ssh-limiter
```

---

## ⚙ Supervisión con Systemd

```bash
# Comprobar estado del servicio
sudo systemctl status ssh-limiter

# Reiniciar el limitador
sudo systemctl restart ssh-limiter

# Detener el limitador
sudo systemctl stop ssh-limiter

# Ver registros de mitigación y eventos en vivo
sudo journalctl -u ssh-limiter -f
```

---

## 🌐 Configuración de Red y Dropbear

El instalador ajusta `/etc/default/dropbear` para permitir conexiones en múltiples puertos simultáneos:

```bash
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 90 -p 109"
```

Puedes gestionar los puertos de Dropbear y reiniciar los servicios directamente desde la opción **[4]** del menú interactivo `menu`.

---

## 📊 Rendimiento y Consumo de Recursos

| Métrica | vps-ssh-limiter | Scripts convencionales (netstat/grep) |
| :--- | :--- | :--- |
| **Uso de CPU** | **< 0.5%** | 5% - 25% (picos continuos) |
| **Memoria RAM** | **~ 4 MB - 8 MB** | Variable (> 30 MB con bases de datos) |
| **I/O Disco** | **Cero (solo lectura /etc/passwd en memoria)** | Escritura continua en logs/BD |
| **Dependencias** | **0 externas (solo herramientas nativas POSIX)** | Python, Node.js, SQLite, MySQL |
| **Tiempo de respuesta** | **Inmediato (inspección /proc en microsegundos)** | Segundos (espera por sockets de red) |

---

## 🗑 Desinstalación

Puedes desinstalar el script desde la opción **[7]** del menú `menu` o ejecutando:

```bash
sudo ./install.sh --uninstall
```

O si utilizas el instalador remoto:
```bash
curl -fsSL "https://raw.githubusercontent.com/sendeiser/tin-script/main/install.sh?v=$(date +%s)" | bash -s -- --uninstall
```

Esto detendrá y eliminará el servicio systemd y retirará todos los binarios y atajos. Los usuarios creados y la configuración de Dropbear se mantendrán intactos.

---

## 📄 Licencia

Este proyecto está bajo la Licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.
