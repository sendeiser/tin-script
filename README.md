# VPS SSH & Dropbear Connection Limiter (`vps-ssh-limiter`)

[![Bash](https://img.shields.io/badge/Language-Bash%205.0%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Platform-Debian%20%7C%20Ubuntu-orange.svg)](https://www.debian.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Systemd](https://img.shields.io/badge/Daemon-Systemd-lightgrey.svg)](https://systemd.io/)

Suite modular, segura y de alto rendimiento diseñada para la administración integral de usuarios SSH y Dropbear en servidores **Debian** y **Ubuntu**, con panel de control interactivo CLI (estilo **Darnyx Script** y **ChumoGH**), control estricto de concurrencia y límites simultáneos por cuenta.

Diseñado siguiendo estándares DevOps para entornos de producción, túneles seguros y reenvío de tráfico (port forwarding), garantizando un consumo de CPU inferior al 1% y cero dependencias de bases de datos externas.

---

## 📑 Tabla de Contenidos

- [Panel Interactivo Principal (menu / tin / vps)](#-panel-interactivo-principal-menu--tin--vps)
- [Arquitectura y Principios de Diseño](#-arquitectura-y-principios-de-diseño)
- [Instalación](#-instalación)
  - [Instalación Rápida (Un Solo Comando)](#instalación-rápida-un-solo-comando)
  - [Instalación Manual](#instalación-manual)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Referencia de Comandos CLI](#-referencia-de-comandos-cli)
  - [menu / tin / vps](#menu--tin--vps)
  - [ssh-useradd](#ssh-useradd)
  - [ssh-usermod](#ssh-usermod)
  - [ssh-userlock](#ssh-userlock)
  - [ssh-killuser](#ssh-killuser)
  - [ssh-userdel](#ssh-userdel)
  - [ssh-online](#ssh-online)
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
──────────────────────────────────────────────────────────────────────────────
 SERVICIOS:  OpenSSH: [ONLINE]   Dropbear: [ONLINE]   Limitador: [ONLINE]
 CUENTAS:    Total: 12     |  Online: 5     |  Expiradas: 1
══════════════════════════════════════════════════════════════════════════════
 [1] ► GESTIÓN DE USUARIOS    (Crear, Renovar, Modificar, Bloquear, Eliminar)
 [2] ► MONITOR DE CONEXIONES  (Tabla en vivo, Modo dinámico en tiempo real)
 [3] ► DEMONIO LIMITADOR      (Estado, Reiniciar, Logs en vivo, Configuración)
 [4] ► PROTOCOLOS Y PUERTOS   (Puertos Dropbear, Reiniciar SSH/Dropbear)
 [5] ► OPTIMIZACIÓN Y SISTEMA (Limpiar RAM/Swap, Acelerador TCP BBR, Info)
 [6] ► ACTUALIZAR / DESINSTALAR SCRIPT
 [0] ► SALIR
══════════════════════════════════════════════════════════════════════════════
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

```
       [Ciclo ssh-limiter]
               │
               ▼
      Leer /etc/passwd (LIM:<N>)
               │
               ▼
   pgrep (OpenSSH + Dropbear)
               │
      ┌────────┴────────┐
      ▼                 ▼
Total <= Límite     Total > Límite
  [OK: Skip]            │
                        ▼
            Ordenar por etimes (ps)
                        │
            Preservar N más antiguas
                        │
            Excedentes: SIGTERM (15)
                        │
                  (Espera 1.5s)
                        │
         ¿Sigue vivo? ──► SIGKILL (9)
```

---

## 🚀 Instalación

### Instalación Rápida (Un Solo Comando)

En tu servidor Debian o Ubuntu, ejecuta como superusuario (`root`):

```bash
curl -fsSL https://raw.githubusercontent.com/sendeiser/tin-script/main/install.sh | bash
```

O si prefieres utilizar `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/sendeiser/tin-script/main/install.sh | bash
```

### Instalación Manual

1. **Clonar o descargar el repositorio:**
   ```bash
   git clone https://github.com/sendeiser/tin-script.git
   cd tin-script
   ```

2. **Otorgar permisos de ejecución:**
   ```bash
   chmod +x install.sh bin/*
   ```

3. **Ejecutar el instalador de producción:**
   ```bash
   sudo ./install.sh
   ```

El instalador se encargará de:
- Instalar dependencias (`dropbear`, `procps`, `iproute2`, `coreutils`, `passwd`).
- Configurar Dropbear en los puertos **143**, **90** y **109** en `/etc/default/dropbear`.
- Registrar `/bin/false` y `/usr/sbin/nologin` en `/etc/shells`.
- Copiar los micro-scripts a `/usr/local/bin` con permisos `755`.
- Configurar los atajos globales `menu`, `tin` y `vps`.
- Instalar, registrar e iniciar el servicio `ssh-limiter.service` en systemd.

---

## 📂 Estructura del Proyecto

```
vps-ssh-limiter/
├── bin/
│   ├── menu                # Panel interactivo estilo Darnyx / ChumoGH (atajos: menu, tin, vps)
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
├── LICENSE                 # Licencia MIT
└── README.md               # Documentación técnica completa
```

---

## 💻 Referencia de Comandos CLI

Todos los binarios se instalan en `/usr/local/bin/`, por lo que se encuentran disponibles globalmente en el `PATH` del sistema y pueden ejecutarse directamente o mediante el menú.

### `menu` / `tin` / `vps`

Abre el Panel de Control Interactivo en pantalla completa con telemetría del servidor en tiempo real.

```bash
sudo menu
```

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

#### Salida en consola:
```text
✔ Usuario creado exitosamente
────────────────────────────────────────────────────
  Usuario:               juan
  Límite simultáneo:     2 conexión(es)
  Fecha de expiración:   2026-10-12 (30 días)
  Shell asignada:        /bin/false
  Directorio de inicio:  /nonexistent (Sin /home)
  Registro GECOS:        LIM:2
────────────────────────────────────────────────────
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

#### Ejemplos:
```bash
sudo ssh-userlock juan lock
sudo ssh-userlock juan unlock
sudo ssh-userlock juan status
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

#### Ejemplo:
```bash
sudo ssh-userdel juan
```

---

### `ssh-online`

Muestra una tabla con el estado de todos los usuarios registrados, sus conexiones SSH y Dropbear en vivo, límites configurados y estado de expiración.

```bash
ssh-online
```

#### Opciones:
- `--no-color`: Desactiva el resaltado ANSI de la salida.
- `--json`: Devuelve los datos en formato JSON estructurado (ideal para bots de Telegram, APIs o paneles web).

#### Salida formateada (Tabla):
```text
========================================================================================
   VPS-SSH-LIMITER :: MONITOR DE CONEXIONES EN TIEMPO REAL  (2026-09-12 20:00:00)
========================================================================================
USUARIO          SSH    DROPBEAR   TOTAL   LÍMITE EXPIRACIÓN    ESTADO            
────────────────────────────────────────────────────────────────────────────────────────
juan             1      1          2       2       2026-10-12     AL LÍMITE
pedro            1      0          1       1       2026-09-30     AL LÍMITE
maria            2      2          4       2       2026-11-01     EXCEDIDO (4/2)
carlos           0      0          0       3       2026-12-15     OFFLINE
ana              1      0          1       2       2026-08-01     EXPIRADO
────────────────────────────────────────────────────────────────────────────────────────
Total Registrados: 5   |   Usuarios Online: 4   |   Conexiones: SSH: 5 | Dropbear: 3 | Total: 8
========================================================================================
```

---

### `ssh-limiter` (Demonio)

Es el servicio en segundo plano que vigila permanentemente los límites. Generalmente es administrado por `systemd`, pero puede ejecutarse directamente para depuración:

```bash
sudo ssh-limiter
```

#### Variables de entorno configurables:
- `CHECK_INTERVAL`: Frecuencia de verificación en segundos (predeterminado: `3`).
- `GRACE_PERIOD`: Tiempo de espera en segundos entre `SIGTERM` y `SIGKILL` (predeterminado: `1.5`).

```bash
CHECK_INTERVAL=5 GRACE_PERIOD=2 sudo ssh-limiter
```

---

## ⚙ Supervisión con Systemd

El servicio queda configurado para iniciarse automáticamente tras el arranque del sistema (`multi-user.target`) y reiniciarse en caso de anomalías:

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

El instalador ajusta de forma desatendida `/etc/default/dropbear` para permitir conexiones en múltiples puertos simultáneos:

```bash
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 90 -p 109"
```

Puedes gestionar los puertos de Dropbear y reiniciar los servicios directamente desde la opción **[4]** del menú interactivo `menu`, o editando `/etc/default/dropbear`.

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

Para eliminar completamente `vps-ssh-limiter` del sistema, puedes seleccionar la opción correspondiente en el menú `menu` o ejecutar:

```bash
sudo ./install.sh --uninstall
```

O si utilizas el script remoto:
```bash
curl -fsSL https://raw.githubusercontent.com/sendeiser/tin-script/main/install.sh | bash -s -- --uninstall
```

Esto detendrá y eliminará el servicio systemd y retirará los binarios de `/usr/local/bin/`. Los usuarios creados y la configuración de Dropbear se mantendrán intactos.

---

## 📄 Licencia

Este proyecto está bajo la Licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.
