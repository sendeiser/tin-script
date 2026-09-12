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
    
    rm -f /etc/systemd/system/ssh-limiter.service
    systemctl daemon-reload 2>/dev/null || true
    
    rm -f /usr/local/bin/ssh-useradd
    rm -f /usr/local/bin/ssh-userdel
    rm -f /usr/local/bin/ssh-online
    rm -f /usr/local/bin/ssh-limite
    
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
    util-linux

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

# Escribir configuración estricta de Dropbea
cat > "$DROPBEAR_DEFAULT" <<'EOF'
# Configuración generada automáticamente por vps-ssh-limite
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 90 -p 109"
DROPBEAR_BANNER=""
DROPBEAR_RECEIVE_WINDOW=65536
EOF

# Habilitar y reiniciar Dropbea
log_info "Reiniciando Dropbear para aplicar nuevos puertos..."
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
# 4. Instalación de Binarios CLI en /usr/local/bin
# ------------------------------------------------------------------------------
log_info "4/5 Instalando comandos en /usr/local/bin..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Si se ejecuta desde el repositorio local
if [[ -d "$SCRIPT_DIR/bin" ]]; then
    install -m 755 "$SCRIPT_DIR/bin/ssh-useradd" /usr/local/bin/ssh-useradd
    install -m 755 "$SCRIPT_DIR/bin/ssh-userdel" /usr/local/bin/ssh-userdel
    install -m 755 "$SCRIPT_DIR/bin/ssh-online"  /usr/local/bin/ssh-online
    install -m 755 "$SCRIPT_DIR/bin/ssh-limiter" /usr/local/bin/ssh-limite
else
    # Soporte para instalación directa vía curl | bash desde GitHub
    BASE_URL="https://raw.githubusercontent.com/sendeiser/tin-script/main"
    log_info "Descargando micro-scripts directamente desde el repositorio..."
    for bin_name in ssh-useradd ssh-userdel ssh-online ssh-limiter; do
        curl -fsSL "${BASE_URL}/bin/${bin_name}" -o "/usr/local/bin/${bin_name}"
        chmod 755 "/usr/local/bin/${bin_name}"
    done
fi

log_success "Binarios instalados con permisos 755 en /usr/local/bin/."

# ------------------------------------------------------------------------------
# 5. Instalación y Activación del Demonio Systemd
# ------------------------------------------------------------------------------
log_info "5/5 Configurando servicio systemd ssh-limiter.service..."

SERVICE_DST="/etc/systemd/system/ssh-limiter.service"
if [[ -f "$SCRIPT_DIR/systemd/ssh-limiter.service" ]]; then
    install -m 644 "$SCRIPT_DIR/systemd/ssh-limiter.service" "$SERVICE_DST"
else
    cat > "$SERVICE_DST" <<'EOF'
[Unit]
Description=VPS SSH & Dropbear Connection Limiter Daemon
Documentation=https://github.com/vps-ssh-limite
After=network.target ssh.service sshd.service dropbear.service
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ssh-limite
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
SyslogIdentifier=ssh-limite

[Install]
WantedBy=multi-user.target
EOF
    chmod 644 "$SERVICE_DST"
fi

# Recargar y arrancar servicio
systemctl daemon-reload
systemctl enable ssh-limiter.service --now
systemctl restart ssh-limiter.service

if systemctl is-active --quiet ssh-limiter; then
    log_success "Servicio ssh-limiter activo y supervisado correctamente por systemd."
else
    log_warn "El servicio ssh-limiter fue instalado pero su estado requiere revisión (systemctl status ssh-limiter)."
fi

# ------------------------------------------------------------------------------
# Resumen y Guía Rápida de Comandos
# ------------------------------------------------------------------------------
echo -e "${C_GRAY}────────────────────────────────────────────────────────────────────────${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}✔ ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${C_RESET}\n"
echo -e "${C_BOLD}Comandos CLI disponibles en el sistema:${C_RESET}"
echo -e "  ${C_CYAN}ssh-useradd <user> <pass> <días> <límite>${C_RESET} : Crear usuario túnel seguro"
echo -e "  ${C_CYAN}ssh-userdel <user>${C_RESET}                       : Revocar y desconectar usuario"
echo -e "  ${C_CYAN}ssh-online${C_RESET}                               : Monitor de conexiones activas en tiempo real"
echo -e "  ${C_CYAN}ssh-online --json${C_RESET}                        : Salida estructurada para APIs o bots"
echo -e ""
echo -e "${C_BOLD}Gestión del Demonio:${C_RESET}"
echo -e "  ${C_GRAY}systemctl status ssh-limiter${C_RESET}             : Ver estado de ejecución"
echo -e "  ${C_GRAY}journalctl -u ssh-limiter -f${C_RESET}             : Registro de eventos en vivo"
echo -e "${C_GRAY}────────────────────────────────────────────────────────────────────────${C_RESET}"

exit 0
