#!/bin/bash

# Installation script for K-Ollama-Plasmoid
# This script handles plasmoid installation for development and production

set -e  # Exit on any error

PROJECT_NAME="K-Ollama-Plasmoid"
PLASMOID_ID="K-Ollama-Plasmoid"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} ${1}"
}

print_error() {
    echo -e "${RED}✗${NC} ${1}"
}

# Function to install for development (local user)
install_dev() {
    print_step "Installing plasmoid for development..."

    # Use kpackagetool6 for proper installation
    if kpackagetool6 --type Plasma/Applet --install .; then
        print_success "Development installation complete"
        print_warning "Restart Plasma to see changes: plasmashell --replace &"
    else
        print_error "Installation failed"
        exit 1
    fi
}

# Function to install system-wide
install_system() {
    print_step "Installing plasmoid system-wide..."

    # Check if running as root or with sudo
    if [ "$EUID" -ne 0 ]; then
        print_error "System installation requires root privileges. Use 'sudo $0 system' or run as root."
        exit 1
    fi

    # Use kpackagetool6 for proper installation
    if kpackagetool6 --type Plasma/Applet --install .; then
        print_success "System installation complete"
        print_warning "Restart Plasma to see changes: systemctl --user restart plasma-plasmashell"
    else
        print_error "Installation failed"
        exit 1
    fi
}

# Function to uninstall plasmoid
uninstall() {
    print_step "Uninstalling plasmoid..."

    local removed=false

    # Try to uninstall using kpackagetool6
    if kpackagetool6 --type Plasma/Applet --remove "${PLASMOID_ID}" 2>/dev/null; then
        print_success "Removed plasmoid using kpackagetool6"
        removed=true
    fi

    # Also check for manual installations and clean them up
    local user_dir="$HOME/.local/share/plasma/plasmoids/${PLASMOID_ID}"
    if [ -d "$user_dir" ]; then
        rm -rf "$user_dir"
        print_success "Removed manual installation from user directory: $user_dir"
        removed=true
    fi

    # Check for system directory (requires root)
    local system_dir="/usr/share/plasma/plasmoids/${PLASMOID_ID}"
    if [ -d "$system_dir" ]; then
        if [ "$EUID" -eq 0 ]; then
            rm -rf "$system_dir"
            print_success "Removed from system directory: $system_dir"
            removed=true
        else
            print_warning "System installation found but not running as root. Use 'sudo $0 uninstall' to remove system installation."
        fi
    fi

    if [ "$removed" = false ]; then
        print_warning "No plasmoid installation found"
    else
        print_warning "Restart Plasma to complete uninstallation: plasmashell --replace &"
    fi
}

# Function to check installation status
status() {
    print_step "Checking installation status..."

    local user_dir="$HOME/.local/share/plasma/plasmoids/${PLASMOID_ID}"
    local system_dir="/usr/share/plasma/plasmoids/${PLASMOID_ID}"

    if [ -d "$user_dir" ]; then
        print_success "Found user installation: $user_dir"
    else
        echo "No user installation found"
    fi

    if [ -d "$system_dir" ]; then
        print_success "Found system installation: $system_dir"
    else
        echo "No system installation found"
    fi

    # Check if plasmoid is registered
    if command -v kpackagetool6 &> /dev/null; then
        echo
        print_step "Checking plasmoid registration..."
        if kpackagetool6 --type Plasma/Applet --list | grep -q "${PLASMOID_ID}"; then
            print_success "Plasmoid is registered with Plasma"
        else
            print_warning "Plasmoid not found in Plasma's package list"
            print_warning "Try: kpackagetool6 --type Plasma/Applet --install ."
        fi
    fi
}

# Function to show usage
usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  dev       Install for development (user directory)"
    echo "  system    Install system-wide (requires root)"
    echo "  uninstall Remove plasmoid from system"
    echo "  status    Check installation status"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev                    # Install for development"
    echo "  sudo $0 system            # Install system-wide"
    echo "  $0 uninstall              # Remove installation"
    echo "  $0 status                 # Check what's installed"
}

# Main script logic
case "${1:-help}" in
    dev|development)
        install_dev
        ;;
    system|sys)
        install_system
        ;;
    uninstall|remove)
        uninstall
        ;;
    status|check)
        status
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        print_error "Unknown command: $1"
        usage
        exit 1
        ;;
esac