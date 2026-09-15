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
- [Gestión y Creación de Dominios / Host](#-gestión-y-creación-de-dominios--host-cloudflare--duckdns--gratis)
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
  - [ssh-domain / domain / dominio](#ssh-domain--domain--dominio)
  - [ssh-useradd](#ssh-useradd)
  - [ssh-usermod](#ssh-usermod)
  - [ssh-userlock](#ssh-userlock)
  - [ssh-killuser](#ssh-killuser)
  - [ssh-userdel](#ssh-userdel)
  - [ssh-online](#ssh-online)
  - [ssh-trial / trial](#-generador-de-cuentas-temporales--trial-ssh-trial--trial)
  - [ssh-udpgw / udpgw](#-badvpn-udp-gateway-en-puerto-7300-ssh-udpgw--udpgw)
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

### Vista Previa del Dashboard (v2.2.0 - Minimalista Compacto):
```text
 ╭───────────────────────────────────────────────────────────╮
 │  ⚡ TIN SCRIPTS • VPS MANAGER             v2.2.0 [ONLINE]  │
 ├─────────────────────────────┬─────────────────────────────┤
 │ OS     : Ubuntu 22.04 LTS   │ IP     : 157.245.62.32      │
 │ Host   : tu-dominio.com     │ Uptime : 5d 12h 30m         │
 │ RAM    : 957/2048 MB (46%)  │ Cuentas: 10 Tot (3 On)      │
 │ CPU    : 2 % (2 Cores)      │ Tráfico: 2.45 GB            │
 ╰─────────────────────────────┴─────────────────────────────╯
 ╭──────────────┬──────────────┬──────────────┬──────────────╮
 │ SSH      [ON]│ DROPBEAR [ON]│ WS-80    [ON]│ UDPGW    [ON]│
 ├──────────────┼──────────────┼──────────────┼──────────────┤
 │ LIMITER  [ON]│ TUNNEL   [ON]│ FAIL2BAN [ON]│ CRON     [ON]│
 ╰──────────────┴──────────────┴──────────────┴──────────────╯
 ╭───────────────────┬───────────────────┬───────────────────╮
 │ [01] USUARIOS SSH │ [06] BANNERS/TEXT │ [11] DOMINIO/DNS  │
 │ [02] CREAR TRIAL  │ [07] RESTART TODO │ [12] TEST VELOCID │
 │ [03] UDPGW 7300   │ [08] LIMITADOR    │ [13] ACTUALIZAR   │
 │ [04] MONITOR VIVO │ [09] PUERTOS/RED  │ [14] DESINSTALAR  │
 │ [05] FICHA CLIENT │ [10] LIMPIAR CACH │ [00] SALIR PANEL  │
 ╰───────────────────┴───────────────────┴───────────────────╯

  ❱❱❱ Seleccione una opción [0-14]: 
```

---

## 🌐 Dominios y Hosts 100% Gratuitos (Asistente Mediado Paso a Paso)

Dispones de un **Asistente Guiado y Mediado** diseñado para usuarios que no desean pagar por un dominio ni lidiar con configuraciones técnicas complejas. Todas las opciones principales son **100% Gratuitas ($0.00)**:

### 1. Métodos y Automatizaciones del Asistente Guiado:
- **⭐ Asistente Guiado Paso a Paso (100% Gratuito - Opción [1]):**
  - Te acompaña con instrucciones simples: *"Paso 1 de 3...", "Paso 2 de 3..."*.
  - Detecta tu IP pública y resuelve todo con valores por defecto (solo presiona `[Enter]`).
  - Al finalizar, **genera automáticamente tu ficha de conexión completa con el Payload listo para copiar y pegar en HTTP Custom**.
- **Dominio Instantáneo 1-Click (`sslip.io` - Cero Registro):**
  - **Costo: $0.00**. No requiere correos, cuentas ni contraseñas.
  - Genera al instante `vps-<ip>.sslip.io` con resolución DNS inmediata a nivel mundial.
- **DuckDNS Personalizado (`*.duckdns.org` - 100% Gratuito para siempre):**
  - Te guía paso a paso para abrir `duckdns.org`, iniciar sesión con Google y elegir tu nombre (`tunombre.duckdns.org`).
  - El script vincula la IP pública y programa un cron job que lo **renueva automáticamente cada 4 horas**.
- **Cloudflare API (Plan Gratuito $0):**
  - Si ya tienes cuenta gratuita en Cloudflare, detecta tus dominios activos automáticamente sin pedirte Zone IDs.
- **Diagnóstico DNS en Vivo:** Prueba la resolución global de tu dominio distinguiendo si está en modo Cloudflare CDN (IPs Anycast) o DNS Directo a tu VPS.

### 2. Atajos Rápidos por Terminal:
```bash
# Abrir el Asistente Guiado Paso a Paso directamente:
domain --wizard
# O también:
ssh-domain --wizard

# Abrir el menú completo de dominios:
domain
```

---

## ⚡ WebSocket Proxy en Puerto 80 (Cloudflare CDN / HTTP Custom)

Para conectar mediante **HTTP Custom**, **HTTP Injector** u otras apps usando payloads con **`Upgrade: websocket`** y Cloudflare CDN:

### 1. ¿Por qué es necesario el WebSocket Proxy en el puerto 80?
Los servidores SSH como **Dropbear** u **OpenSSH** esperan una cabecera de protocolo nativa (`SSH-2.0...`). Si un cliente envía una petición HTTP (`GET / HTTP/1.1 ... Upgrade: websocket`), Dropbear o SSH cierran la conexión de inmediato reportando `Protocol mismatch`.
El servicio **`ssh-wsproxy`** escucha en el **puerto 80**:
1. Recibe la petición HTTP con el encabezado WebSocket.
2. Devuelve automáticamente la respuesta esperada: `HTTP/1.1 101 Switching Protocols`.
3. Establece un túnel TCP transparente bidireccional conectando directamente con el puerto interno de Dropbear (`127.0.0.1:143`).

### 2. ¿Cómo funciona la arquitectura con Bug Host y Cloudflare?
```text
[Teléfono Móvil (HTTP Custom)]
       │
       ▼ (1) Envía Payload con Bug Host (rexo.personal.com.ar) y Upgrade: websocket
[Antena / DPI del Operador] ──► Deja pasar el tráfico gratis en puerto 80 (Zero-Rating)
       │
       ▼ (2) Conecta a Cloudflare CDN (ej: woocommerce.everlytic.net:80)
[Cloudflare Edge Anycast] ──► Lee 'Host: martin.supravps.shop'
       │
       ▼ (3) Reenvía WebSocket hacia la IP de tu VPS en puerto 80
[Servidor VPS (ssh-wsproxy:80)] ──► Responde 101 Switching Protocols
       │
       ▼ (4) Entrega la sesión SSH localmente
[Dropbear (127.0.0.1:143)] ──► ¡Sesión SSH Autenticada y Conectada!
```

### 3. Asistente Guiado Paso a Paso (Opción [7] -> [1] o `ssh-httpcustom --wizard`)
El menú interactivo incluye un generador automático que te guía paso a paso:
1. Elige tu operadora o escribe tu Bug Host (Personal, Claro, Movistar, WhatsApp).
2. Detecta tu subdominio configurado en la VPS (`martin.supravps.shop`).
3. Te sugiere dominios CDN de Cloudflare probados (ej: `woocommerce.everlytic.net`).
4. Selecciona tu usuario túnel registrado.
5. Genera la ficha completa con el Payload listo para copiar y los datos exactos para la app.

### 4. Alternativas a Cloudflare (Opción [7] -> [2] o `ssh-httpcustom --alternatives`)
Si no deseas usar Cloudflare o tu operadora presenta bloqueos sobre sus IPs:
- **Alternativa 1: WebSocket Directo en Puerto 80 (Sin Cloudflare)**
  - Te conectas directo a la IP de tu VPS o a un dominio gratuito de 1-Click (`sslip.io` / `DuckDNS`) en el puerto 80. Menor latencia, cero configuración externa y el tráfico es gestionado directamente por `ssh-wsproxy`.
- **Alternativa 2: Conexión Cifrada SSL / TLS con SNI Spoofing (Puerto 443)**
  - No requiere CDN. Conectas al puerto 443 marcando `SSL` en HTTP Custom e ingresando el Bug Host en el campo **SNI**. El tráfico viaja completamente encriptado por TLS.
- **Alternativa 3: Otras Redes CDN Globales (Fastly, Gcore, BunnyCDN)**
  - Redes alternativas de alta velocidad con soporte WebSocket (Gcore cuenta con 1 TB mensual gratuito y servidores en Sudamérica; Fastly permite origins HTTP directos).

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

### 3. Ficha Automática para Enviar a Clientes (Móvil / Mensajes)
Al crear cualquier cuenta desde el menú o con `ssh-useradd`, se genera automáticamente una ficha lista para copiar y enviar:
```text
🚀 *DATOS DE TU CUENTA SSH / HTTP CUSTOM*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 *Host / IP:* 198.51.100.24
🚪 *Puertos Dropbear:* 143, 90, 109 (Recomendados)
🚪 *Puerto WebSocket Proxy:* 80 (Para Payloads / CDN Cloudflare)
🚪 *Puerto OpenSSH:* 22
👤 *Usuario:* juan
🔑 *Contraseña:* clave123
📅 *Vencimiento:* 2026-10-12 (30 día(s) restantes)
📊 *Datos Usados:* 342.5 MB
📱 *Límite de Conexiones:* 2 dispositivo(s)
📞 *Contacto / Soporte:* 3826432180
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ *Formato Rápido de Importación en HTTP Custom:*
198.51.100.24:143@juan:clave123
```

### 4. Recomendaciones Anti-Desconexiones:
- **Activar Auto-Ping:** En el menú lateral de HTTP Custom, activa **Auto Ping** con un intervalo de **3 a 5 segundos** para mantener el socket SSH siempre activo.
- **Batería sin restricciones:** En Android -> Ajustes -> Aplicaciones -> HTTP Custom -> Batería -> "Sin restricciones" para evitar que el sistema cierre la app en segundo plano.
- **Respetar el límite simultáneo:** Si el cliente supera el límite asignado (por ejemplo, 2 conexiones), el demonio `ssh-limiter` cerrará de inmediato la conexión excedente más reciente.

---

## 🎨 Gestor de Banners Optimizados para Celulares (Apps & SSH)

El sistema incluye un módulo completo de **Banners y Mensajes Informativos 100% Optimizados para Pantallas Móviles** (ancho de 41 caracteres exactos para evitar que los marcos se rompan o desborden en aplicaciones como **HTTP Custom, HTTP Injector, NapsternetV** o clientes SSH de Android):

### 1. Funcionalidades del Módulo de Banners:
- **Banner Pre-Auth en Apps (Ancho 41 cols):** Se muestra perfectamente encuadrado en el registro (log) de conexión de HTTP Custom nada más pulsar *Connect*.
- **Plantillas Estilizadas Móviles (41 columnas):**
  - `[1] ★ Información de Cuenta (HTTP Custom Móvil)`: Cuadro de cuenta, servidor, estado, fecha/hora, tráfico total y teléfono `3826432180`.
  - `[2] ★ VIP Gold Móvil (Elegante)`: Enfoque comercial con estrellas doradas y contacto oficial.
  - `[3] 🔹 Clean Minimal Móvil`: Diseño compacto y de máxima legibilidad en cualquier smartphone.
  - `[4] 🎮 Gaming & Low-Lag Móvil`: Optimizado para juegos online (Free Fire/PUBG/COD) y ping bajo.
  - `[5] 📝 Editor Libre`: Editor manual para escribir tu propio diseño.
- **Banner Dinámico de Sesión de Usuario (Login / SSH Móvil):**
  Calcula y muestra en tiempo real al conectarse el usuario:
  - 👤 **Nombre de usuario:** `$USER`
  - 📅 **Fecha de vencimiento y días restantes:** Formateado automáticamente
  - 📊 **Consumo de datos de internet:** En MB / GB acumulados y en vivo
  - 📱 **Cuota de conexiones activas:** `X de Y dispositivos permitidos`
  - 🚀 **Estado de la cuenta:** `ACTIVO Y OPTIMIZADO`
  - 🕒 **Fecha y hora del servidor:** En tiempo real (`DD/MM/AAAA HH:MM`)
  - 📞 **Contacto / Soporte:** `3826432180` (Sin redes sociales)
  - ⚠️ **Reglas de seguridad:** Prohibición de Torrent, Spam y Multi-Login

### 2. Comandos Rápidos:
```bash
# Abrir el menú interactivo de banners:
banner
# O también:
ssh-banner

# Previsualizar el banner actual en vista móvil:
banner --preview

# Activar plantilla rápidamente (1 a 4):
banner --template 1
```

---

## 🔄 Actualizador Automático en el Menú

El sistema cuenta con **detección inteligente de versiones**:
1. Cada vez que abres el menú, consulta en segundo plano la última versión disponible en GitHub.
2. Si detecta una nueva actualización, la opción **`[8] ► ACTUALIZAR SCRIPT`** se resalta automáticamente con una alerta visual:
   ```text
   [8] ► ACTUALIZAR SCRIPT ★ ¡NUEVA ACTUALIZACIÓN vX.Y.Z DISPONIBLE! ★
   ```
3. Al presionar **`8`**, el actualizador:
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

## ⏱️ Generador de Cuentas Temporales / Trial (`ssh-trial` / `trial`)

Permite generar cuentas SSH/Dropbear/WS instantáneas con auto-expiración y auto-borrado garantizado para pruebas o demostraciones de clientes:

- **Nombre aleatorio o personalizado:** `trialXXXX` generado en un clic.
- **Duración configurable:** 30 minutos, 60 minutos (1h), 120 minutos (2h), 24 horas o minutos personalizados.
- **Auto-borrado garantizado:** Usa temporizadores transitorios de `systemd-run` y demonio `at`. Al expirar el tiempo, el sistema desconecta las sesiones activas y elimina al usuario de `/etc/passwd`.
- **Ficha instantánea para HTTP Custom:** Imprime la clave, fecha/hora exacta de vencimiento y el ticket directo `host:puerto@usuario:clave` listo para copiar y enviar al cliente por WhatsApp o Telegram.

```bash
# Ejecución interactiva:
sudo trial
# O también:
sudo ssh-trial
```

---

## 🎮 BadVPN UDP Gateway en Puerto 7300 (`ssh-udpgw` / `udpgw`)

Habilita el reenvío de paquetes UDP encapsulados en el túnel SSH para aplicaciones como **HTTP Custom**, **OpenVPN** y clientes VPN móviles:

- **Escucha interna:** `127.0.0.1:7300` con capacidad para 500 clientes concurrentes.
- **Indispensable para:**
  - Juegos en línea (Free Fire, Mobile Legends, PUBG Mobile, Call of Duty).
  - Llamadas y videollamadas por VoIP (WhatsApp, Telegram, Discord).
- **Supervisión Systemd:** Servicio `badvpn-udpgw.service` con autoarranque y reinicio automático.

```bash
# Menú de gestión de BadVPN UDPGW:
sudo udpgw
# Comandos rápidos:
sudo ssh-udpgw --status
sudo ssh-udpgw --restart
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
│   ├── ssh-domain          # CLI: Gestor de dominios y DNS (Cloudflare API, DuckDNS, sslip.io) (atajos: domain, dominio)
│   ├── ssh-httpcustom      # CLI: Guía, payloads y fichas para HTTP Custom (atajos: httpcustom, custom)
│   ├── ssh-update          # CLI: Actualizador automático desde GitHub (atajo: update)
│   ├── ssh-useradd         # CLI: Creación de usuarios con límite GECOS y expiración
│   ├── ssh-usermod         # CLI: Renovación de días, modificación de cuota y cambio de clave
│   ├── ssh-userlock        # CLI: Bloqueo/desbloqueo de cuentas con expulsión de sesiones
│   ├── ssh-killuser        # CLI: Desconexión forzosa de sesiones por usuario o masiva
│   ├── ssh-userdel         # CLI: Revocación forzosa y expulsión inmediata de procesos
│   ├── ssh-online          # CLI: Monitor en tiempo real con tabla formateada y JSON
│   ├── ssh-wsproxy         # CLI/Demonio: WebSocket Proxy puerto 80 hacia Dropbear (atajo: wsproxy)
│   └── ssh-limiter         # Demonio de monitoreo y mitigación escalonada
├── systemd/
│   ├── ssh-limiter.service # Definición de unidad systemd para supervisión continua
│   └── ssh-wsproxy.service # Definición de unidad systemd para WebSocket Proxy en puerto 80
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

Muestra una tabla en tiempo real con el estado de todos los usuarios registrados, conexiones SSH y Dropbear en vivo, consumo de datos de internet (`DATOS USADOS`), límites de cuota, fecha de expiración y tráfico total acumulado del servidor:

```bash
ssh-online
# O en formato JSON para bots y paneles web (incluye bytes de tráfico por usuario y servidor):
ssh-online --json
```

---

### `ssh-domain` / `domain` / `dominio`

Gestión y vinculación de dominios y subdominios hacia la IP del VPS (Cloudflare API, DuckDNS, sslip.io, validación DNS):

```bash
# Abrir el menú interactivo de dominios:
domain
# O también:
dominio
# O comando completo:
ssh-domain

# Ver el dominio actualmente configurado en el servidor:
ssh-domain --show

# Diagnóstico de propagación DNS del dominio actual:
ssh-domain --check

# Ver la guía y tutorial paso a paso:
ssh-domain --guide

# Asignar un dominio propio directamente por parámetro:
sudo ssh-domain --set midominio.com

# Asignar un dominio gratuito instantáneo (sslip.io):
sudo ssh-domain --instant

# Borrar credenciales guardadas de Cloudflare o DuckDNS:
sudo ssh-domain --cf-clear
sudo ssh-domain --duck-clear

# Eliminar el dominio configurado y volver a usar solo la IP:
sudo ssh-domain --unset
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

### `ssh-wsproxy` / `wsproxy`

Proxy WebSocket de alto rendimiento en el **puerto 80**, diseñado para recibir peticiones `Upgrade: websocket` de Cloudflare CDN y HTTP Custom y reenviarlas hacia Dropbear (`127.0.0.1:143`):

```bash
# Ver estado del WebSocket Proxy y puertos:
wsproxy --status

# Iniciar el servicio en segundo plano (systemd):
sudo wsproxy --start

# Detener el servicio:
sudo wsproxy --stop

# Reiniciar el servicio:
sudo wsproxy --restart

# Ejecutar directamente en primer plano (escucha 80 -> destino 143):
sudo wsproxy 80 127.0.0.1:143
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

Puedes desinstalar el script desde la opción **[9]** del menú `menu` o ejecutando:

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
