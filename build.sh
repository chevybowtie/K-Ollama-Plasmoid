#!/bin/bash

# Build script for K-Ollama-Plasmoid
# This script handles the complete build and installation process

set -e  # Exit on any error

PROJECT_NAME="K-Ollama-Plasmoid"
BUILD_DIR="build"

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

# Function to check if required tools are installed
check_dependencies() {
    print_step "Checking dependencies..."
    
    local missing_deps=()
    
    # Check for CMake
    if ! command -v cmake &> /dev/null; then
        missing_deps+=("cmake")
    fi
    
    # Check for gettext tools
    if ! command -v xgettext &> /dev/null; then
        missing_deps+=("gettext")
    fi
    
    if ! command -v msgfmt &> /dev/null; then
        missing_deps+=("gettext")
    fi
    
    # Check for Qt6 and KDE development packages
    if ! pkg-config --exists Qt6Core; then
        missing_deps+=("qt6-base-dev")
    fi
    
    # Check for KDE Plasma development packages
    if ! pkg-config --exists KF6Plasma 2>/dev/null && ! pkg-config --exists KF5Plasma 2>/dev/null; then
        missing_deps+=("libkf6plasma-dev")
    fi
    
    # Check for KDE i18n development packages  
    if ! pkg-config --exists KF6I18n 2>/dev/null && ! pkg-config --exists KF5I18n 2>/dev/null; then
        missing_deps+=("libkf6i18n-dev")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo
        echo "Package installation commands for different distributions:"
        echo
        echo "Ubuntu/Debian:"
        echo "  sudo apt install ${missing_deps[*]} extra-cmake-modules libkf6plasma-dev libkf6i18n-dev"
        echo
        echo "Fedora:"
        echo "  sudo dnf install cmake gettext qt6-qtbase-devel extra-cmake-modules kf6-plasma-devel kf6-ki18n-devel"
        echo
        echo "Arch Linux:"
        echo "  sudo pacman -S cmake gettext qt6-base extra-cmake-modules plasma-framework ki18n"
        echo
        echo "openSUSE:"
        echo "  sudo zypper install cmake gettext-tools qt6-base-devel extra-cmake-modules plasma6-framework-devel ki18n-devel"
        echo
        exit 1
    fi
    
    print_success "All dependencies found"
}

# Function to extract and update translations
update_translations() {
    print_step "Updating translations..."
    
    if [ -f "${BUILD_DIR}/Makefile" ]; then
        cd "${BUILD_DIR}"
        make extract-messages
        if [ $? -eq 0 ]; then
            make update-translations 2>/dev/null || true
            print_success "Translations updated"
        else
            print_warning "Could not extract messages (build project first)"
        fi
        cd ..
    else
        print_warning "Build directory not found. Run 'configure' first."
    fi
}

# Function to configure the build
configure() {
    print_step "Configuring build..."
    
    # Create build directory
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"
    
    # Configure with CMake
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
    
    if [ $? -eq 0 ]; then
        print_success "Configuration complete"
    else
        print_error "Configuration failed"
        exit 1
    fi
    
    cd ..
}

# Function to build the project
build() {
    print_step "Building project..."
    
    if [ ! -f "${BUILD_DIR}/Makefile" ]; then
        print_error "Project not configured. Run './build.sh configure' first."
        exit 1
    fi
    
    cd "${BUILD_DIR}"
    make -j$(nproc)
    
    if [ $? -eq 0 ]; then
        print_success "Build complete"
    else
        print_error "Build failed"
        exit 1
    fi
    
    cd ..
}

# Function to install the plasmoid
install() {
    print_step "Installing plasmoid..."
    
    if [ ! -f "${BUILD_DIR}/Makefile" ]; then
        print_error "Project not built. Run './build.sh build' first."
        exit 1
    fi
    
    cd "${BUILD_DIR}"
    sudo make install
    
    if [ $? -eq 0 ]; then
        print_success "Installation complete"
        print_warning "Restart Plasma to see changes: systemctl --user restart plasma-plasmashell"
    else
        print_error "Installation failed"
        exit 1
    fi
    
    cd ..
}

# Function to clean build artifacts
clean() {
    print_step "Cleaning build artifacts..."
    rm -rf "${BUILD_DIR}"
    print_success "Clean complete"
}

# Function to run tests
test() {
    print_step "Running test suite..."
    
    if [ -f "scripts/run-tests.sh" ]; then
        ./scripts/run-tests.sh
        if [ $? -eq 0 ]; then
            print_success "All tests passed"
        else
            print_error "Some tests failed"
            exit 1
        fi
    else
        print_error "Test script not found at scripts/run-tests.sh"
        exit 1
    fi
}

# Function to show usage
usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deps       Check and install dependencies"
    echo "  configure  Configure the build system"
    echo "  build      Build the project"
    echo "  install    Install the plasmoid system-wide"
    echo "  translate  Update translation files"
    echo "  test       Run test suite"
    echo "  clean      Clean build artifacts"
    echo "  all        Configure, build, and install (complete workflow)"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 all                    # Complete build and install"
    echo "  $0 configure && $0 build  # Configure and build only"
    echo "  $0 translate              # Update translations"
    echo "  $0 test                   # Run tests"
}

# Main script logic
case "${1:-help}" in
    deps|dependencies)
        check_dependencies
        ;;
    configure|config)
        check_dependencies
        configure
        ;;
    build|make)
        build
        ;;
    install)
        install
        ;;
    translate|translations)
        update_translations
        ;;
    test|tests)
        test
        ;;
    clean)
        clean
        ;;
    all)
        check_dependencies
        configure
        build
        test
        install
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