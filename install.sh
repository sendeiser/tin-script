#!/usr/bin/env bash
# ==============================================================================
# vps-ssh-limiter: install.sh
# Instalador desatendido de producción para Debian y Ubuntu.
# Configura dependencias, puertos de Dropbear (143, 90, 109), shells restringidas,
# binarios CLI en /usr/local/bin y activa el servicio systemd ssh-limiter.
# ==============================================================================
set -euo pipefail

# ------------------------------------------------------------------------------
# Configuración visual (colores y formato)
# ------------------------------------------------------------------------------
if [[ -t 1 ]]; then
    C_RESET="\033[0m"
    C_RED="\033[1;31m"
    C_GREEN="\033[1;32m"
    C_YELLOW="\033[1;33m"
    C_BLUE="\033[1;34m"
    C_CYAN="\033[1;36m"
    C_BOLD="\033[1m"
    C_GRAY="\033[0;90m"
else
    C_RESET=""
    C_RED=""
    C_GREEN=""
    C_YELLOW=""
    C_BLUE=""
    C_CYAN=""
    C_BOLD=""
    C_GRAY=""
fi

log_info() {
    echo -e "${C_CYAN}[INFO]${C_RESET} $*"
}

log_success() {
    echo -e "${C_GREEN}[OK]${C_RESET} $*"
}

log_warn() {
    echo -e "${C_YELLOW}[AVISO]${C_RESET} $*"
}

log_error() {
    echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2
}

# ------------------------------------------------------------------------------
# Verificación de Privilegios de Superusuario
# ------------------------------------------------------------------------------
if [[ "$(id -u)" -ne 0 ]]; then
    log_error "Este instalador debe ejecutarse como root (o mediante sudo)."
    exit 1
fi

# ------------------------------------------------------------------------------
# Detección del Sistema Operativo (Debian / Ubuntu)
# ------------------------------------------------------------------------------
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_ID="${ID:-}"
    OS_ID_LIKE="${ID_LIKE:-}"
    OS_NAME="${PRETTY_NAME:-$OS_ID}"
else
    log_error "No se pudo identificar la distribución del sistema (/etc/os-release ausente)."
    exit 1
fi

case "$OS_ID" in
    debian|ubuntu|raspbian)
        log_info "Sistema detectado compatible: ${C_BOLD}$OS_NAME${C_RESET}"
        ;;
    *)
        if [[ "$OS_ID_LIKE" =~ (debian|ubuntu) ]]; then
            log_warn "Distribución derivada detectada ($OS_NAME). Continuando..."
        else
            log_error "Este paquete está diseñado específicamente para distribuciones Debian y Ubuntu."
            log_error "Distribución reportada: $OS_NAME"
            exit 1
        fi
        ;;
esac

# ------------------------------------------------------------------------------
# Desinstalación opcional si se pasa el flag --uninstall
# ------------------------------------------------------------------------------
if [[ "${1:-}" == "--uninstall" ]]; then
    log_info "Iniciando proceso de desinstalación de vps-ssh-limiter..."
    
    if systemctl is-active --quiet ssh-limiter 2>/dev/null; then
        systemctl stop ssh-limiter 2>/dev/null || true
    fi
    if systemctl is-enabled --quiet ssh-limiter 2>/dev/null; then
        systemctl disable ssh-limiter 2>/dev/null || true
    fi
    
    if systemctl is-active --quiet ssh-wsproxy 2>/dev/null; then
        systemctl stop ssh-wsproxy 2>/dev/null || true
    fi
    if systemctl is-enabled --quiet ssh-wsproxy 2>/dev/null; then
        systemctl disable ssh-wsproxy 2>/dev/null || true
    fi
    
    rm -f /etc/systemd/system/ssh-limiter.service /etc/systemd/system/ssh-wsproxy.service
    systemctl daemon-reload 2>/dev/null || true
    
    for b in ssh-useradd ssh-userdel ssh-usermod ssh-userlock ssh-killuser ssh-online ssh-limiter ssh-update ssh-httpcustom httpcustom custom ssh-domain domain dominio ssh-wsproxy wsproxy update menu tin vps; do
        rm -f "/usr/local/bin/$b" "/usr/bin/$b"
    done
    rm -rf /etc/vps-ssh-limiter
    
    log_success "vps-ssh-limiter ha sido desinstalado correctamente del sistema."
    exit 0
fi

# ------------------------------------------------------------------------------
# Banner de Instalación
# ------------------------------------------------------------------------------
echo -e "${C_CYAN}${C_BOLD}"
cat <<'EOF'
  __   ______  ____        ____ ____  _   _     _     ___ __  __ ___ _____ _____ ____  
  \ \ / /  _ \/ ___|      / ___/ ___|| | | |   | |   |_ _|  \/  |_ _|_   _| ____|  _ \ 
   \ V /| |_) \___ \ _____\___ \___ \| |_| |   | |    | || |\/| || |  | | |  _| | |_) |
    \_/ | .__/ ___) |_____|___) |__) |  _  |   | |___ | || |  | || |  | | | |___|  _ < 
        |_|   |____/      |____/____/|_| |_|   |_____|___|_|  |_|___| |_| |_____|_| \_\
EOF
echo -e "${C_RESET}"
echo -e "${C_GRAY}Instalador automatizado de alta eficiencia para SSH & Dropbear${C_RESET}"
echo -e "${C_GRAY}────────────────────────────────────────────────────────────────────────${C_RESET}"

# ------------------------------------------------------------------------------
# 1. Instalación de Dependencias del Sistema
# ------------------------------------------------------------------------------
log_info "1/5 Actualizando repositorios e instalando paquetes necesarios..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq -y
apt-get install -y -qq \
    dropbear \
    procps \
    iproute2 \
    coreutils \
    passwd \
    gawk \
    sed \
    util-linux \
    dnsutils \
    python3

log_success "Dependencias instaladas con éxito."

# ------------------------------------------------------------------------------
# 2. Configuración Segura de Dropbear (Puertos 143, 90, 109)
# ------------------------------------------------------------------------------
log_info "2/5 Configurando servicio Dropbear en puertos 143, 90 y 109..."

DROPBEAR_DEFAULT="/etc/default/dropbear"
if [[ -f "$DROPBEAR_DEFAULT" ]]; then
    # Respaldo de seguridad previo
    cp "$DROPBEAR_DEFAULT" "${DROPBEAR_DEFAULT}.bak.$(date +%s)"
fi

# Escribir configuración estricta de Dropbear
cat > "$DROPBEAR_DEFAULT" <<'EOF'
# Configuración generada automáticamente por vps-ssh-limiter
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 90 -p 109"
DROPBEAR_BANNER=""
DROPBEAR_RECEIVE_WINDOW=65536
EOF

# Habilitar y reiniciar Dropbear (desactivar dropbear.socket para permitir puertos 143, 90, 109)
log_info "Reiniciando Dropbear para aplicar nuevos puertos..."
systemctl stop dropbear.socket 2>/dev/null || true
systemctl disable dropbear.socket 2>/dev/null || true
systemctl enable dropbear 2>/dev/null || true
systemctl restart dropbear 2>/dev/null || /etc/init.d/dropbear restart 2>/dev/null || true

log_success "Dropbear configurado y activo en puertos 143, 90 y 109."

# ------------------------------------------------------------------------------
# 3. Validación y Registro de Shells Restringidas en /etc/shells
# ------------------------------------------------------------------------------
log_info "3/5 Garantizando compatibilidad de shells restringidas en /etc/shells..."

SHELLS_FILE="/etc/shells"
for target_shell in "/bin/false" "/usr/sbin/nologin"; do
    if ! grep -Fxq "$target_shell" "$SHELLS_FILE" 2>/dev/null; then
        echo "$target_shell" >> "$SHELLS_FILE"
        log_info "Añadido $target_shell a $SHELLS_FILE"
    fi
done

log_success "Shells restringidas autorizadas para autenticación sin apertura de sesión interactiva."

# ------------------------------------------------------------------------------
# 4. Instalación de Binarios CLI y Menú en /usr/local/bin
# ------------------------------------------------------------------------------
log_info "4/5 Instalando comandos y panel interactivo en /usr/local/bin..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_LIST=(ssh-useradd ssh-userdel ssh-usermod ssh-userlock ssh-killuser ssh-online ssh-limiter ssh-update ssh-httpcustom ssh-domain ssh-wsproxy menu)

# Si se ejecuta desde un archivo de script local real que contiene bin/menu
if [[ -n "${BASH_SOURCE[0]:-}" && -f "$SCRIPT_DIR/bin/menu" ]]; then
    for bin_name in "${BIN_LIST[@]}"; do
        if [[ -f "$SCRIPT_DIR/bin/${bin_name}" ]]; then
            install -m 755 "$SCRIPT_DIR/bin/${bin_name}" "/usr/local/bin/${bin_name}"
        fi
    done
else
    # Descarga directa vía GitHub con cache-busting para evitar cachés de CDN
    BASE_URL="https://raw.githubusercontent.com/sendeiser/tin-script/main"
    TIMESTAMP=$(date +%s)
    log_info "Descargando suite completa desde GitHub..."
    for bin_name in "${BIN_LIST[@]}"; do
        curl -fsSL "${BASE_URL}/bin/${bin_name}?v=${TIMESTAMP}" -o "/usr/local/bin/${bin_name}"
        chmod 755 "/usr/local/bin/${bin_name}"
    done
fi

# Crear enlaces simbólicos globales en /usr/local/bin y /usr/bin para compatibilidad universal con PATH
ln -sf /usr/local/bin/menu /usr/local/bin/tin
ln -sf /usr/local/bin/menu /usr/local/bin/vps
ln -sf /usr/local/bin/ssh-update /usr/local/bin/update
ln -sf /usr/local/bin/ssh-httpcustom /usr/local/bin/httpcustom
ln -sf /usr/local/bin/ssh-httpcustom /usr/local/bin/custom
ln -sf /usr/local/bin/ssh-domain /usr/local/bin/domain
ln -sf /usr/local/bin/ssh-domain /usr/local/bin/dominio
ln -sf /usr/local/bin/ssh-wsproxy /usr/local/bin/wsproxy

for bin_name in "${BIN_LIST[@]}" tin vps update httpcustom custom domain dominio wsproxy; do
    ln -sf "/usr/local/bin/${bin_name}" "/usr/bin/${bin_name}" 2>/dev/null || true
done

# Registrar versión instalada y configuración por defecto
mkdir -p /etc/vps-ssh-limiter
echo "1.7.3" > /etc/vps-ssh-limiter/version

if [[ ! -f /etc/vps-ssh-limiter/wsproxy.conf ]]; then
    cat > /etc/vps-ssh-limiter/wsproxy.conf <<'EOF'
LISTEN_PORT=80
TARGET_HOST=127.0.0.1
TARGET_PORT=143
EOF
fi

log_success "Binarios y atajos ('menu', 'update', 'domain', 'httpcustom', 'wsproxy', 'tin', 'vps') vinculados."

# ------------------------------------------------------------------------------
# 5. Instalación y Activación de Demonios Systemd (ssh-limiter & ssh-wsproxy)
# ------------------------------------------------------------------------------
log_info "5/5 Configurando servicios systemd ssh-limiter y ssh-wsproxy (Puerto 80)..."

SERVICE_DST="/etc/systemd/system/ssh-limiter.service"
if [[ -f "$SCRIPT_DIR/systemd/ssh-limiter.service" ]]; then
    install -m 644 "$SCRIPT_DIR/systemd/ssh-limiter.service" "$SERVICE_DST"
else
    cat > "$SERVICE_DST" <<'EOF'
[Unit]
Description=VPS SSH & Dropbear Connection Limiter Daemon
Documentation=https://github.com/sendeiser/tin-script
After=network.target ssh.service sshd.service dropbear.service
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ssh-limiter
Restart=always
RestartSec=5
KillMode=process
TimeoutStopSec=10
Environment=CHECK_INTERVAL=3
Environment=GRACE_PERIOD=1.5
LimitNOFILE=65536
TasksMax=infinity
StandardOutput=journal
StandardError=journal
SyslogIdentifier=ssh-limiter

[Install]
WantedBy=multi-user.target
EOF
    chmod 644 "$SERVICE_DST"
fi

WS_SERVICE_DST="/etc/systemd/system/ssh-wsproxy.service"
if [[ -f "$SCRIPT_DIR/systemd/ssh-wsproxy.service" ]]; then
    install -m 644 "$SCRIPT_DIR/systemd/ssh-wsproxy.service" "$WS_SERVICE_DST"
else
    cat > "$WS_SERVICE_DST" <<'EOF'
[Unit]
Description=VPS WebSocket Proxy for SSH & Dropbear (Port 80)
Documentation=https://github.com/sendeiser/tin-script
After=network.target dropbear.service ssh.service sshd.service
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ssh-wsproxy --run
Restart=always
RestartSec=3
KillMode=process
TimeoutStopSec=5
LimitNOFILE=65536
TasksMax=infinity
StandardOutput=journal
StandardError=journal
SyslogIdentifier=ssh-wsproxy

[Install]
WantedBy=multi-user.target
EOF
    chmod 644 "$WS_SERVICE_DST"
fi

# Recargar y arrancar servicios
systemctl daemon-reload
systemctl enable ssh-limiter.service --now 2>/dev/null || true
systemctl restart ssh-limiter.service 2>/dev/null || true

systemctl enable ssh-wsproxy.service --now 2>/dev/null || true
systemctl restart ssh-wsproxy.service 2>/dev/null || true

if systemctl is-active --quiet ssh-limiter; then
    log_success "Servicio ssh-limiter activo y supervisado por systemd."
else
    log_warn "El servicio ssh-limiter requiere revisión (systemctl status ssh-limiter)."
fi

if systemctl is-active --quiet ssh-wsproxy; then
    log_success "Servicio ssh-wsproxy activo en el puerto 80 (systemd)."
else
    log_warn "El servicio ssh-wsproxy requiere revisión (systemctl status ssh-wsproxy)."
fi

# ------------------------------------------------------------------------------
# Resumen y Guía Rápida de Comandos
# ------------------------------------------------------------------------------
echo -e "${C_GRAY}────────────────────────────────────────────────────────────────────────${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}✔ ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${C_RESET}\n"
echo -e "${C_BOLD}Acceso al Panel y Actualizaciones:${C_RESET}"
echo -e "  ${C_BOLD}${C_GREEN}menu${C_RESET}   (o ${C_CYAN}tin${C_RESET} / ${C_CYAN}vps${C_RESET})     : Abre el panel interactivo completo"
echo -e "  ${C_BOLD}${C_YELLOW}update${C_RESET} (o ${C_CYAN}ssh-update${C_RESET})  : Actualiza el script automáticamente a la última versión"
echo -e ""
echo -e "${C_BOLD}Comandos CLI directos disponibles:${C_RESET}"
echo -e "  ${C_CYAN}ssh-useradd <u|p|d|l>${C_RESET}  : Crear usuario túnel restringido"
echo -e "  ${C_CYAN}ssh-usermod <u|opciones>${C_RESET}: Renovar días, límite o contraseña"
echo -e "  ${C_CYAN}ssh-userlock <u|lock|unlock>${C_RESET}: Bloquear o desbloquear cuenta"
echo -e "  ${C_CYAN}ssh-killuser <u|--all-exceeded>${C_RESET}: Desconectar sesiones activas"
echo -e "  ${C_CYAN}ssh-userdel <usuario>${C_RESET}      : Revocar y eliminar usuario"
echo -e "  ${C_CYAN}ssh-online${C_RESET}             : Monitor de conexiones en tiempo real (--json para APIs)"
echo -e "  ${C_CYAN}ssh-httpcustom [usuario]${C_RESET}: Generador de fichas y guía para HTTP Custom (atajos: httpcustom, custom)"
echo -e "  ${C_CYAN}ssh-domain${C_RESET}               : Gestor de dominios Cloudflare/DuckDNS/Gratis (atajos: domain, dominio)"
echo -e "  ${C_CYAN}ssh-wsproxy${C_RESET}              : WebSocket Proxy puerto 80 para HTTP Custom / CDN (atajo: wsproxy)"
echo -e ""
echo -e "${C_BOLD}Supervisión de Servicios:${C_RESET}"
echo -e "  ${C_GRAY}systemctl status ssh-limiter${C_RESET}   : Estado del limitador de conexiones"
echo -e "  ${C_GRAY}systemctl status ssh-wsproxy${C_RESET}   : Estado del WebSocket Proxy (Puerto 80)"
echo -e "  ${C_GRAY}journalctl -u ssh-limiter -f${C_RESET}   : Registros del limitador en vivo"
echo -e "  ${C_GRAY}journalctl -u ssh-wsproxy -f${C_RESET}   : Registros del WebSocket Proxy en vivo"
echo -e "${C_GRAY}────────────────────────────────────────────────────────────────────────${C_RESET}"

exit 0
