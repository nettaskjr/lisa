#!/bin/bash
# Instalador do Lisa - Sistema de Backup
# Licença: MIT

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Versão do instalador
INSTALLER_VERSION="1.0.0"

# Diretórios padrão
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/lisa"
LOG_DIR="/var/log"

# Função para imprimir mensagens
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se é root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "Este script precisa ser executado como root (use sudo)"
        exit 1
    fi
}

# Detectar diretório do script
get_script_dir() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$SCRIPT_DIR"
}

# Verificar dependências
check_dependencies() {
    info "Verificando dependências..."
    
    local missing_deps=()
    
    if ! command -v rsync >/dev/null 2>&1; then
        missing_deps+=("rsync")
    fi
    
    if ! command -v blkid >/dev/null 2>&1; then
        missing_deps+=("util-linux")
    fi
    
    if ! command -v lsblk >/dev/null 2>&1; then
        missing_deps+=("util-linux")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "Dependências faltando: ${missing_deps[*]}"
        warn "Instale as dependências antes de continuar:"
        
        if command -v apt-get >/dev/null 2>&1; then
            echo "  sudo apt-get update && sudo apt-get install -y rsync util-linux"
        elif command -v yum >/dev/null 2>&1; then
            echo "  sudo yum install -y rsync util-linux"
        elif command -v dnf >/dev/null 2>&1; then
            echo "  sudo dnf install -y rsync util-linux"
        elif command -v pacman >/dev/null 2>&1; then
            echo "  sudo pacman -S rsync util-linux"
        else
            echo "  Instale: rsync e util-linux"
        fi
        
        exit 1
    fi
    
    info "Todas as dependências estão instaladas"
}

# Instalar o script
install_lisa() {
    local script_dir
    script_dir=$(get_script_dir)
    
    info "Instalando Lisa..."
    
    # Verificar se o arquivo lisa existe
    if [ ! -f "$script_dir/lisa" ]; then
        error "Arquivo 'lisa' não encontrado em $script_dir"
        exit 1
    fi
    
    # Criar diretório de instalação se não existir
    mkdir -p "$INSTALL_DIR"
    
    # Copiar script
    info "Copiando lisa para $INSTALL_DIR..."
    cp "$script_dir/lisa" "$INSTALL_DIR/lisa"
    chmod +x "$INSTALL_DIR/lisa"
    
    # Criar diretório de configuração
    mkdir -p "$CONFIG_DIR"
    
    # Se houver arquivo hd no diretório do script, copiar para config
    if [ -f "$script_dir/hd" ]; then
        info "Copiando configuração existente..."
        cp "$script_dir/hd" "$CONFIG_DIR/hd"
        chmod 600 "$CONFIG_DIR/hd"
    else
        info "Arquivo de configuração será criado na primeira execução"
    fi
    
    # Se houver arquivo excludes no diretório do script, copiar para config
    if [ -f "$script_dir/excludes" ]; then
        info "Copiando arquivo de exclusões..."
        cp "$script_dir/excludes" "$CONFIG_DIR/excludes"
        chmod 644 "$CONFIG_DIR/excludes"
    else
        info "Arquivo de exclusões não encontrado (opcional)"
    fi
    
    # Criar diretório de log se não existir
    mkdir -p "$LOG_DIR"
    
    info "Lisa instalado com sucesso em $INSTALL_DIR/lisa"
}

# Criar link simbólico (opcional)
create_symlink() {
    if [ -L "$INSTALL_DIR/lisa-backup" ]; then
        warn "Link simbólico já existe, pulando..."
        return
    fi
    
    info "Criando link simbólico lisa-backup..."
    ln -sf "$INSTALL_DIR/lisa" "$INSTALL_DIR/lisa-backup"
    info "Você pode usar 'lisa' ou 'lisa-backup' para executar"
}

# Verificar instalação
verify_installation() {
    info "Verificando instalação..."
    
    if [ ! -f "$INSTALL_DIR/lisa" ]; then
        error "Instalação falhou: arquivo não encontrado"
        exit 1
    fi
    
    if [ ! -x "$INSTALL_DIR/lisa" ]; then
        error "Instalação falhou: arquivo não é executável"
        exit 1
    fi
    
    # Verificar sintaxe
    if ! bash -n "$INSTALL_DIR/lisa" 2>/dev/null; then
        error "Instalação falhou: erro de sintaxe no script"
        exit 1
    fi
    
    info "Instalação verificada com sucesso!"
    echo ""
    echo "Para usar o Lisa, execute:"
    echo "  sudo lisa"
    echo ""
    echo "Ou:"
    echo "  sudo lisa-backup"
    echo ""
    echo "Nota: O Lisa precisa ser executado como root para montar dispositivos."
}

# Desinstalar
uninstall() {
    info "Desinstalando Lisa..."
    
    if [ -f "$INSTALL_DIR/lisa" ]; then
        rm -f "$INSTALL_DIR/lisa"
        info "Script removido"
    fi
    
    if [ -L "$INSTALL_DIR/lisa-backup" ]; then
        rm -f "$INSTALL_DIR/lisa-backup"
        info "Link simbólico removido"
    fi
    
    if [ -d "$CONFIG_DIR" ]; then
        read -p "Deseja remover a configuração em $CONFIG_DIR? (s/N): " -r
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            rm -rf "$CONFIG_DIR"
            info "Configuração removida"
        else
            info "Configuração mantida em $CONFIG_DIR"
        fi
    fi
    
    if [ -f "$CONFIG_DIR/excludes" ]; then
        read -p "Deseja remover o arquivo de exclusões? (s/N): " -r
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            rm -f "$CONFIG_DIR/excludes"
            info "Arquivo de exclusões removido"
        fi
    fi
    
    info "Lisa desinstalado"
}

# Menu principal
main() {
    echo "=========================================="
    echo "  Instalador do Lisa v$INSTALLER_VERSION"
    echo "  Sistema de Backup com rsync"
    echo "=========================================="
    echo ""
    
    # Verificar argumentos
    case "${1:-install}" in
        install)
            check_root
            check_dependencies
            install_lisa
            create_symlink
            verify_installation
            ;;
        uninstall)
            check_root
            uninstall
            ;;
        check)
            check_dependencies
            if [ -f "$INSTALL_DIR/lisa" ]; then
                info "Lisa está instalado em $INSTALL_DIR/lisa"
                verify_installation
            else
                warn "Lisa não está instalado"
            fi
            ;;
        *)
            echo "Uso: $0 {install|uninstall|check}"
            echo ""
            echo "  install   - Instalar o Lisa (padrão)"
            echo "  uninstall - Remover o Lisa"
            echo "  check     - Verificar dependências e instalação"
            exit 1
            ;;
    esac
}

# Executar
main "$@"

