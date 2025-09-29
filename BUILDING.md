# Development Guide

## Build System Overview

This project uses CMake as the build system with automatic translation support.

### Quick Start

```bash
# Complete build and install
./build.sh all

# Or step by step:
./build.sh configure  # Configure CMake
./build.sh build      # Build the project  
./build.sh install    # Install system-wide
```

### Translation Workflow

#### Adding New Languages

1. **Extract strings** (automatic):
   ```bash
   ./build.sh translate
   ```

2. **Create new language file**:
   ```bash
   cp po/K-Ollama-Plasmoid.pot po/fr.po  # For French
   ```

3. **Edit translation**:
   Edit `po/fr.po` and fill in `msgstr` entries

4. **Build and install**:
   ```bash
   ./build.sh build install
   ```

#### Updating Existing Translations

1. **Extract new strings**:
   ```bash
   cd build && make extract-messages
   ```

2. **Update translation files**:
   ```bash
   cd build && make update-translations
   ```

3. **Edit updated files** and rebuild

### Build Targets

| Target | Description |
|--------|-------------|
| `all` | Default target, builds everything |
| `translations` | Compiles all .po files to .mo |
| `extract-messages` | Extracts translatable strings to .pot |
| `update-translations` | Updates .po files from .pot |

### Directory Structure

```
├── CMakeLists.txt           # Main build configuration
├── build.sh                 # Primary build automation script
├── contents/                # Plasmoid source files
│   ├── config/             # Configuration UI
│   └── ui/                 # Main UI components
├── po/                     # Translation files
│   ├── CMakeLists.txt      # Translation build config
│   ├── *.pot               # Translation template
│   ├── *.po                # Language-specific translations
│   └── *.mo                # Compiled translations (generated)
├── scripts/                # Utility and development scripts
│   ├── run-tests.sh        # Test runner script
│   └── install-translations.sh  # Translation installation utility
└── build/                  # Build output (generated)
```

### Script Organization

Following standard conventions:

**Root Level Scripts** (essential workflow):
- `build.sh` - Primary build and development script

**Scripts Directory** (utilities and specialized tools):
- `scripts/run-tests.sh` - Test suite runner
- `scripts/install-translations.sh` - Direct translation installation

### Dependencies

#### Required
- CMake (≥ 3.16)
- Qt6 Core and Quick
- KDE Frameworks 6 (Plasma, I18n, ConfigWidgets)
- gettext tools

#### Install Dependencies

**Debian/Ubuntu (KF6 - preferred):**
```bash
sudo apt install cmake extra-cmake-modules \
    qt6-base-dev libkf6plasma-dev libkf6i18n-dev \
    libkf6configwidgets-dev gettext
```

**Debian/Ubuntu (KF5 - fallback):**
```bash
sudo apt install cmake extra-cmake-modules \
    qtbase5-dev libkf5plasma-dev libkf5i18n-dev \
    libkf5configwidgets-dev gettext
```

**Fedora:**
```bash
sudo dnf install cmake extra-cmake-modules \
    qt6-qtbase-devel kf6-plasma-devel kf6-ki18n-devel \
    kf6-kconfigwidgets-devel gettext
```

**Arch Linux:**
```bash
sudo pacman -S cmake extra-cmake-modules \
    qt6-base plasma-framework ki18n kconfigwidgets gettext
```

**openSUSE:**
```bash
sudo zypper install cmake extra-cmake-modules \
    qt6-base-devel plasma6-framework-devel ki18n-devel \
    kconfigwidgets-devel gettext-tools
```

### Advanced Usage

#### Custom Install Prefix
```bash
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
make install
```

#### Debug Build
```bash
cd build  
cmake .. -DCMAKE_BUILD_TYPE=Debug
make
```

#### Packaging
```bash
cd build
make package  # Creates .tar.gz
cpack -G DEB  # Creates .deb package
```

## Troubleshooting

### Missing KDE Framework Packages

**Problem**: `Package 'libkf6plasma-dev' has no installation candidate`

**Solution**: Your distribution might not have KF6 packages yet. Try KF5 alternatives:

```bash
# Instead of KF6 packages, use KF5:
sudo apt install cmake extra-cmake-modules \
    qtbase5-dev libkf5plasma-dev libkf5i18n-dev \
    libkf5configwidgets-dev gettext
```

**Check what's available:**
```bash
# Search for available plasma packages
apt search plasma.*dev | grep -i plasma

# Search for available ki18n packages  
apt search ki18n.*dev
```

### CMake Configuration Issues

**Problem**: CMake can't find Qt or KDE packages

**Solution**: Ensure pkg-config can find the packages:
```bash
# Test if packages are detectable
pkg-config --exists Qt6Core && echo "Qt6 OK" || echo "Qt6 missing"
pkg-config --exists KF6Plasma && echo "KF6 OK" || pkg-config --exists KF5Plasma && echo "KF5 OK" || echo "Plasma missing"
```