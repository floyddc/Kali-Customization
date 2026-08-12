#!/usr/bin/env bash

# ============================================================
# Kali Automatic Customization
#
# Based on:
# https://github.com/floyddc/Kali-Customization
#
# Do NOT run as root.
# ============================================================

set -Eeuo pipefail

REPO_URL="https://github.com/floyddc/Kali-Customization.git"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

WORK_DIR="$(mktemp -d /tmp/kali-customization.XXXXXX)"
BACKUP_DIR="$HOME/.kali-customization-backup-$(date +%Y%m%d-%H%M%S)"

OHMYZSH_DIR="/etc/oh-my-zsh"
P10K_DIR="$OHMYZSH_DIR/themes/powerlevel10k"

USER_BIN="$HOME/.local/bin"
QTERMINAL_CONFIG_DIR="$HOME/.config/qterminal.org"
QTERMINAL_CONFIG="$QTERMINAL_CONFIG_DIR/qterminal.ini"

# Number of Xfce workspaces
WORKSPACES=8


# ============================================================
# FUNCTIONS
# ============================================================

cleanup() {
    rm -rf "$WORK_DIR"
}

error_handler() {
    echo
    echo "[ERROR] Installation failed at line $1."
    echo
}

trap cleanup EXIT
trap 'error_handler "$LINENO"' ERR


# ============================================================
# CHECKS
# ============================================================

if [[ "$EUID" -eq 0 ]]; then
    echo "[ERROR] Do not run this script as root."
    echo
    echo "Use:"
    echo "  ./kali-customization.sh"
    exit 1
fi

if [[ ! -f /etc/os-release ]]; then
    echo "[ERROR] Cannot identify operating system."
    exit 1
fi

source /etc/os-release

if [[ "${ID:-}" != "kali" ]]; then
    echo "[WARNING] This does not appear to be Kali Linux."
    echo "Detected: ${PRETTY_NAME:-unknown}"
    echo

    read -r -p "Continue anyway? [y/N] " ANSWER

    if [[ ! "$ANSWER" =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

if ! command -v sudo >/dev/null 2>&1; then
    echo "[ERROR] sudo is not installed."
    exit 1
fi

sudo -v

# Keep sudo alive
(
    while true; do
        sudo -n true
        sleep 45
        kill -0 "$$" 2>/dev/null || exit
    done
) >/dev/null 2>&1 &

SUDO_KEEPALIVE=$!

cleanup_sudo() {
    kill "$SUDO_KEEPALIVE" 2>/dev/null || true
    cleanup
}

trap cleanup_sudo EXIT


# ============================================================
# BACKUP
# ============================================================

echo "[+] Creating backup..."

mkdir -p "$BACKUP_DIR"

backup_user() {
    local path="$1"

    if [[ -e "$path" ]]; then
        cp -a "$path" "$BACKUP_DIR/" 2>/dev/null || true
    fi
}

backup_system() {
    local path="$1"

    if sudo test -e "$path"; then
        sudo cp -a "$path" "$BACKUP_DIR/" 2>/dev/null || true
    fi
}

backup_user "$HOME/.zshrc"
backup_user "$HOME/.bashrc"
backup_user "$HOME/.config/xfce4"
backup_user "$HOME/.config/qterminal.org"
backup_user "$HOME/.config/autostart"

backup_system "/etc/zsh"
backup_system "/etc/polybar"
backup_system "/etc/rofi"
backup_system "/etc/vivid"
backup_system "/etc/lsd"
backup_system "/etc/.p10k.zsh"

echo "[+] Backup: $BACKUP_DIR"


# ============================================================
# SYSTEM UPDATE
# ============================================================

echo "[+] Updating system..."

sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt -y full-upgrade


# ============================================================
# PACKAGES
# ============================================================

echo "[+] Installing packages..."

PACKAGES=(
    polybar
    bspwm
    wmctrl
    tmux
    xbindkeys
    lsd
    vivid
    xclip
    bat
    rofi
    devilspie2

    git
    curl
    tar
    xz-utils
    fontconfig
    zsh

    qterminal
    xfconf
    xfce4-settings
    xfdesktop4
    xfce4-panel
    xfce4-session
    xfwm4

    firefox-esr
    thunar
)

sudo DEBIAN_FRONTEND=noninteractive apt install -y "${PACKAGES[@]}"


# ============================================================
# DOWNLOAD REPOSITORY
# ============================================================

echo "[+] Downloading customization repository..."

git clone \
    --depth=1 \
    "$REPO_URL" \
    "$WORK_DIR/repo"

REPO_DIR="$WORK_DIR/repo"


# ============================================================
# VALIDATE REPOSITORY
# ============================================================

REQUIRED_FILES=(
    "lsd/lsd_config.yaml"
    "lsd/lsd_colors.yaml"

    "polybar/polybar_config.ini"
    "polybar/target_setter.sh"
    "polybar/powermenu.sh"
    "polybar/polybar.desktop"

    "vivid/vivid_theme.yml"

    "rofi/rofi_theme.rasi"

    "qterminal-borders/qterminal.lua"
    "qterminal-borders/qterminal.conf"
    "qterminal-borders/devilspie2.desktop"

    "ohmyzsh-p10k/globalZshrc"
    "ohmyzsh-p10k/rootZshrc"
    "ohmyzsh-p10k/p10k"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$REPO_DIR/$file" ]]; then
        echo "[ERROR] Missing repository file: $file"
        exit 1
    fi
done


# ============================================================
# JETBRAINS MONO NERD FONT
# ============================================================

echo "[+] Installing JetBrainsMono Nerd Font..."

FONT_DIR="$WORK_DIR/font"

mkdir -p "$FONT_DIR"

curl -fL \
    "$FONT_URL" \
    -o "$FONT_DIR/JetBrainsMono.tar.xz"

sudo mkdir -p /usr/share/fonts/truetype/JetBrainsMono

sudo tar \
    -xf "$FONT_DIR/JetBrainsMono.tar.xz" \
    -C /usr/share/fonts/truetype/JetBrainsMono

sudo fc-cache -f


# ============================================================
# LSD
# ============================================================

echo "[+] Configuring lsd..."

sudo mkdir -p /etc/lsd

sudo install -m 644 \
    "$REPO_DIR/lsd/lsd_config.yaml" \
    /etc/lsd/config.yaml

sudo install -m 644 \
    "$REPO_DIR/lsd/lsd_colors.yaml" \
    /etc/lsd/colors.yaml


# ============================================================
# POLYBAR
# ============================================================

echo "[+] Configuring Polybar..."

sudo mkdir -p /etc/polybar/scripts

sudo install -m 644 \
    "$REPO_DIR/polybar/polybar_config.ini" \
    /etc/polybar/config.ini

sudo install -m 755 \
    "$REPO_DIR/polybar/target_setter.sh" \
    /etc/polybar/scripts/target_setter.sh

sudo install -m 755 \
    "$REPO_DIR/polybar/powermenu.sh" \
    /etc/polybar/scripts/powermenu.sh

sudo install -m 644 \
    "$REPO_DIR/polybar/polybar.desktop" \
    /etc/xdg/autostart/polybar.desktop


# ============================================================
# VIVID
# ============================================================

echo "[+] Configuring vivid..."

sudo mkdir -p /etc/vivid/themes

sudo install -m 644 \
    "$REPO_DIR/vivid/vivid_theme.yml" \
    /etc/vivid/themes/theme.yml


# ============================================================
# ROFI
# ============================================================

echo "[+] Configuring Rofi..."

sudo mkdir -p /etc/rofi
sudo mkdir -p /usr/share/rofi/themes

sudo install -m 644 \
    "$REPO_DIR/rofi/rofi_theme.rasi" \
    /usr/share/rofi/themes/theme.rasi


# ============================================================
# QTERMINAL / DEVILSPIE2
# ============================================================

echo "[+] Configuring QTerminal / Devilspie2..."

sudo mkdir -p /etc/skel/.config/devilspie2
sudo mkdir -p /etc/xdg/qterminal.org
sudo mkdir -p /etc/xdg/autostart

sudo install -m 644 \
    "$REPO_DIR/qterminal-borders/qterminal.lua" \
    /etc/skel/.config/devilspie2/qterminal.lua

sudo install -m 644 \
    "$REPO_DIR/qterminal-borders/qterminal.conf" \
    /etc/xdg/qterminal.org/qterminal.conf

sudo install -m 644 \
    "$REPO_DIR/qterminal-borders/devilspie2.desktop" \
    /etc/xdg/autostart/devilspie2.desktop


# ============================================================
# QTERMINAL USER PREFERENCES
# ============================================================

echo "[+] Configuring QTerminal preferences..."

mkdir -p "$QTERMINAL_CONFIG_DIR"

# If QTerminal has never been opened, create a minimal config.
if [[ ! -f "$QTERMINAL_CONFIG" ]]; then
    cat > "$QTERMINAL_CONFIG" <<'EOF'
[General]
AskOnExit=false
MenuVisible=false
TerminalTransparency=10
colorScheme=Linux
fontSize=12

[Shortcuts]
Quit=Ctrl+Q
Split%20View%20Left-Right=Ctrl+V
Split%20View%20Top-Bottom=Ctrl+H
Close%20Tab=Ctrl+W
EOF
else

    # General settings
    sed -i \
        's/^fontSize=.*/fontSize=12/' \
        "$QTERMINAL_CONFIG"

    sed -i \
        's/^colorScheme=.*/colorScheme=Linux/' \
        "$QTERMINAL_CONFIG"

    sed -i \
        's/^TerminalTransparency=.*/TerminalTransparency=10/' \
        "$QTERMINAL_CONFIG"

    sed -i \
        's/^MenuVisible=.*/MenuVisible=false/' \
        "$QTERMINAL_CONFIG"

    # Shortcuts
    sed -i \
        's/^Quit=.*/Quit=Ctrl+Q/' \
        "$QTERMINAL_CONFIG"

    sed -i \
        's/^Split%20View%20Left-Right=.*/Split%20View%20Left-Right=Ctrl+V/' \
        "$QTERMINAL_CONFIG"

    sed -i \
        's/^Split%20View%20Top-Bottom=.*/Split%20View%20Top-Bottom=Ctrl+H/' \
        "$QTERMINAL_CONFIG"

    sed -i \
        's/^Close%20Tab=.*/Close%20Tab=Ctrl+W/' \
        "$QTERMINAL_CONFIG"
fi


# ============================================================
# OH-MY-ZSH
# ============================================================

echo "[+] Installing Oh-My-Zsh..."

if [[ ! -d "$OHMYZSH_DIR" ]]; then

    git clone \
        --depth=1 \
        https://github.com/ohmyzsh/ohmyzsh.git \
        "$WORK_DIR/ohmyzsh"

    sudo mv \
        "$WORK_DIR/ohmyzsh" \
        "$OHMYZSH_DIR"

fi


# ============================================================
# POWERLEVEL10K
# ============================================================

echo "[+] Installing Powerlevel10k..."

if [[ ! -d "$P10K_DIR" ]]; then

    sudo git clone \
        --depth=1 \
        https://github.com/romkatv/powerlevel10k.git \
        "$P10K_DIR"

fi


# ============================================================
# ZSH CONFIGURATION
# ============================================================

echo "[+] Configuring Zsh..."

sudo install -m 644 \
    "$REPO_DIR/ohmyzsh-p10k/globalZshrc" \
    /etc/zsh/zshrc

sudo install -m 644 \
    "$REPO_DIR/ohmyzsh-p10k/p10k" \
    /etc/.p10k.zsh

sudo install -m 644 \
    "$REPO_DIR/ohmyzsh-p10k/rootZshrc" \
    /root/.zshrc


# Configure existing users
while IFS=: read -r username _ uid _ _ home _; do

    if [[ "$uid" -ge 1000 && "$uid" -lt 60000 ]] &&
       [[ -d "$home" ]]; then

        cat > "$home/.zshrc" <<'EOF'
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /etc/zsh/zshrc

[[ ! -f /etc/.p10k.zsh ]] || source /etc/.p10k.zsh
EOF

        chown "$username:$username" "$home/.zshrc"
        chmod 644 "$home/.zshrc"
    fi

done < /etc/passwd


# New users
sudo tee /etc/skel/.zshrc >/dev/null <<'EOF'
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /etc/zsh/zshrc

[[ ! -f /etc/.p10k.zsh ]] || source /etc/.p10k.zsh
EOF

sudo chmod 644 /etc/skel/.zshrc


# Current user's default shell
CURRENT_USER="$(id -un)"
ZSH_PATH="$(command -v zsh)"
CURRENT_SHELL="$(getent passwd "$CURRENT_USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    sudo chsh -s "$ZSH_PATH" "$CURRENT_USER"
fi


# ============================================================
# XFCE SHORTCUTS
# ============================================================

echo "[+] Configuring Xfce shortcuts..."

if command -v xfconf-query >/dev/null 2>&1; then

    xfconf-query \
        -c xfce4-keyboard-shortcuts \
        -p '/commands/custom/<Super>Return' \
        -n -t string \
        -s 'qterminal' 2>/dev/null || true

    xfconf-query \
        -c xfce4-keyboard-shortcuts \
        -p '/commands/custom/<Super>r' \
        -n -t string \
        -s 'rofi -show run -config /usr/share/rofi/themes/theme.rasi' \
        2>/dev/null || true

    xfconf-query \
        -c xfce4-keyboard-shortcuts \
        -p '/commands/custom/<Super>b' \
        -n -t string \
        -s 'firefox' 2>/dev/null || true

    xfconf-query \
        -c xfce4-keyboard-shortcuts \
        -p '/commands/custom/<Super>f' \
        -n -t string \
        -s 'thunar' 2>/dev/null || true

fi


# ============================================================
# XFCE DESKTOP
# ============================================================

echo "[+] Configuring Xfce desktop..."

if command -v xfconf-query >/dev/null 2>&1; then

    # Disable right-click application menu
    xfconf-query \
        -c xfce4-desktop \
        -p '/desktop-menu/show' \
        -n -t bool \
        -s false 2>/dev/null || true

    # Disable middle-click window list
    xfconf-query \
        -c xfce4-desktop \
        -p '/windowlist-menu/show' \
        -n -t bool \
        -s false 2>/dev/null || true

    # Disable desktop icons
    xfconf-query \
        -c xfce4-desktop \
        -p '/desktop-icons/style' \
        -n -t int \
        -s 0 2>/dev/null || true

    # Workspaces
    xfconf-query \
        -c xfwm4 \
        -p '/general/workspace_count' \
        -n -t int \
        -s "$WORKSPACES" 2>/dev/null || true

fi


# ============================================================
# XFCE BACKGROUND
# ============================================================

echo "[+] Configuring desktop background..."

if command -v xfconf-query >/dev/null 2>&1; then

    BACKDROP_PATHS="$(
        xfconf-query \
            -c xfce4-desktop \
            -lv 2>/dev/null |
        awk '/color-style$/ {
            sub(/\/color-style$/, "", $1)
            print $1
        }' |
        sort -u
    )"

    if [[ -z "$BACKDROP_PATHS" ]]; then
        BACKDROP_PATHS="/backdrop/screen0/monitor0/workspace0"
    fi

    while IFS= read -r BACKDROP; do

        [[ -z "$BACKDROP" ]] && continue

        # Solid color
        xfconf-query \
            -c xfce4-desktop \
            -p "$BACKDROP/color-style" \
            -n -t int \
            -s 0 2>/dev/null || true

        # #161515
        xfconf-query \
            -c xfce4-desktop \
            -p "$BACKDROP/rgba1" \
            -n \
            -t double \
            -t double \
            -t double \
            -t double \
            -s 0.0862745 \
            -s 0.0823529 \
            -s 0.0823529 \
            -s 1.0 2>/dev/null || true

    done <<< "$BACKDROP_PATHS"

fi


# ============================================================
# DISABLE XFCE PANEL
# ============================================================

echo "[+] Disabling Xfce panel..."

AUTOSTART_DIR="$HOME/.config/autostart"

mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/disable-panel.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Disable Panel
Comment=Disable Xfce panel at login
Exec=xfce4-panel --quit
Terminal=false
StartupNotify=false
OnlyShowIn=XFCE;
X-GNOME-Autostart-enabled=true
EOF

chmod 644 "$AUTOSTART_DIR/disable-panel.desktop"


# ============================================================
# BASH ALIASES
# ============================================================

echo "[+] Configuring aliases..."

BASHRC="$HOME/.bashrc"

touch "$BASHRC"

sed -i \
    '/# >>> KALI CUSTOMIZATION >>>/,/# <<< KALI CUSTOMIZATION <<</d' \
    "$BASHRC"

cat >> "$BASHRC" <<'EOF'

# >>> KALI CUSTOMIZATION >>>

alias cls='clear'
alias ls='lsd -l'
alias lst='lsd --tree'
alias cat='batcat'
alias off='poweroff'

# <<< KALI CUSTOMIZATION <<<

EOF


# ============================================================
# USER COMMANDS
# ============================================================

echo "[+] Installing custom commands..."

mkdir -p "$USER_BIN"


# ------------------------------------------------------------
# settarget
# ------------------------------------------------------------

cat > "$USER_BIN/settarget" <<'EOF'
#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: settarget <IP>"
    exit 1
fi

TARGET="$1"

printf '%s\n' "$TARGET" > /tmp/target_address.txt

echo "[+] TARGET: $TARGET"

if pgrep -x polybar >/dev/null 2>&1; then
    polybar-msg cmd restart >/dev/null 2>&1 || true
fi
EOF

chmod 755 "$USER_BIN/settarget"


# ------------------------------------------------------------
# extractPorts
# ------------------------------------------------------------

cat > "$USER_BIN/extractPorts" <<'EOF'
#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: extractPorts <file>"
    exit 1
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
    echo "[-] File not found: $FILE"
    exit 1
fi

PORTS="$(
    grep -oE '[0-9]+/open' "$FILE" 2>/dev/null |
    cut -d/ -f1 |
    sort -n |
    uniq |
    paste -sd, -
)"

if [[ -z "$PORTS" ]]; then
    echo "[-] No open ports found."
    exit 1
fi

echo "[+] Open ports:"
echo "$PORTS"

if command -v xclip >/dev/null 2>&1; then
    printf '%s' "$PORTS" | xclip -selection clipboard
    echo "[+] Copied to clipboard."
fi
EOF

chmod 755 "$USER_BIN/extractPorts"


# ============================================================
# PATH
# ============================================================

if ! grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$BASHRC"; then

    cat >> "$BASHRC" <<'EOF'

export PATH="$HOME/.local/bin:$PATH"
EOF

fi


# ============================================================
# REFRESH
# ============================================================

echo "[+] Refreshing font cache..."

fc-cache -f >/dev/null

echo "[+] Reloading Xfce desktop..."

xfdesktop --reload >/dev/null 2>&1 || true

echo "[+] Stopping current Polybar..."

polybar-msg cmd quit >/dev/null 2>&1 || true

echo "[+] Stopping current Devilspie2..."

pkill -x devilspie2 >/dev/null 2>&1 || true


# ============================================================
# CHECK
# ============================================================

echo
echo "============================================================"
echo "Installation completed."
echo "============================================================"
echo

echo "Installed:"
echo "  - Polybar"
echo "  - Rofi"
echo "  - lsd"
echo "  - vivid"
echo "  - JetBrainsMono Nerd Font"
echo "  - QTerminal"
echo "  - Devilspie2"
echo "  - Oh-My-Zsh"
echo "  - Powerlevel10k"
echo "  - Xfce shortcuts"
echo "  - Xfce desktop configuration"
echo "  - Disabled Xfce panel"
echo "  - settarget"
echo "  - extractPorts"
echo

echo "QTerminal:"
echo "  Font size:     12 pt"
echo "  Color scheme:  Linux"
echo "  Transparency:  10%"
echo "  Menu bar:      OFF"
echo

echo "QTerminal shortcuts:"
echo "  Ctrl + Q       Quit"
echo "  Ctrl + V       Split vertical"
echo "  Ctrl + H       Split horizontal"
echo "  Ctrl + W       Close"
echo

echo "Xfce shortcuts:"
echo "  Super + Enter  QTerminal"
echo "  Super + R      Rofi"
echo "  Super + B      Firefox"
echo "  Super + F      Thunar"
echo

echo "Commands:"
echo "  settarget <IP>"
echo "  extractPorts <file>"
echo

echo "Backup:"
echo "  $BACKUP_DIR"
echo

echo "============================================================"
echo
echo "Restart Kali to apply all changes:"
echo
echo "  sudo reboot"
echo
echo "============================================================"