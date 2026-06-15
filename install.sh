#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1"; }
err()    { echo -e "${RED}[✗]${NC} $1" >&2; }
confirm(){ read -rp "Proceed? (y/N): " ans; [[ "$ans" =~ ^[Yy]$ ]]; }

check_root() {
    if [[ $EUID -eq 0 ]]; then
        err "Do not run this script as root."
        exit 1
    fi
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_LIKE=$ID_LIKE
    else
        err "Cannot detect distribution. /etc/os-release not found."
        exit 1
    fi
    log "Detected distro: $PRETTY_NAME"
}

install_python() {
    log "Installing Python 3 and pip..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv build-essential

    if command -v python3 &>/dev/null; then
        log "Python $(python3 --version) installed."
    else
        err "Python installation failed."
        return 1
    fi
}

install_vscode() {
    if command -v code &>/dev/null; then
        warn "VS Code is already installed. Skipping."
        return 0
    fi

    log "Installing VS Code..."

    if command -v snap &>/dev/null; then
        sudo snap install code --classic
    else
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo apt update
        sudo apt install -y code
    fi

    log "VS Code installed."
}

install_intellij() {
    if command -v intellij-idea-community &>/dev/null; then
        warn "IntelliJ is already installed. Skipping."
        return 0
    fi

    log "Installing IntelliJ IDEA Community..."

    if command -v snap &>/dev/null; then
        sudo snap install intellij-idea-community --classic
    else
        warn "Snap not available. Installing JetBrains Toolbox..."
        wget -qO /tmp/jetbrains-toolbox.tar.gz "https://download.jetbrains.com/toolbox/jetbrains-toolbox-latest.tar.gz"
        tar -xzf /tmp/jetbrains-toolbox.tar.gz -C /opt/
        /opt/jetbrains-toolbox-*/jetbrains-toolbox.sh &
        warn "Toolbox launched. Install IntelliJ IDEA Community from its GUI."
    fi

    log "IntelliJ installed."
}

install_chrome() {
    if command -v google-chrome &>/dev/null; then
        warn "Google Chrome is already installed. Skipping."
        return 0
    fi

    log "Installing Google Chrome..."

    wget -qO /tmp/google-chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    sudo apt install -y /tmp/google-chrome.deb || {
        sudo apt install -f -y
        sudo dpkg -i /tmp/google-chrome.deb
    }
    rm -f /tmp/google-chrome.deb

    log "Google Chrome installed."
}

install_brave() {
    if command -v brave-browser &>/dev/null; then
        warn "Brave Browser is already installed. Skipping."
        return 0
    fi

    log "Installing Brave Browser..."

    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install -y brave-browser

    log "Brave Browser installed."
}

main() {
    echo "=========================================="
    echo "  Linux Dev Environment Setup"
    echo "=========================================="
    echo ""

    check_root
    detect_distro

    if [[ "$DISTRO" != "ubuntu" && "$DISTRO" != "debian" && ! "$DISTRO_LIKE" =~ (debian|ubuntu) ]]; then
        warn "This script targets Debian/Ubuntu. Detected: $DISTRO"
        warn "Some installations may fail or require adaptation."
    fi

    echo ""
    echo "The following will be installed:"
    echo "  - Python 3 + pip"
    echo "  - Visual Studio Code"
    echo "  - IntelliJ IDEA Community"
    echo "  - Google Chrome"
    echo "  - Brave Browser"
    echo ""

    if ! confirm; then
        warn "Aborted by user."
        exit 0
    fi

    echo ""
    install_python
    install_vscode
    install_intellij
    install_chrome
    install_brave

    echo ""
    echo "=========================================="
    log "All done! Restart your shell or run: source ~/.bashrc"
    echo "=========================================="
}

main "$@"
