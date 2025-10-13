# Development Guide

## Overview

This is a KDE Plasma 6 plasmoid written entirely in QML and JavaScript1. **Extract new strings:**
   ```bash
   ./scripts/translate.sh extract
   ```
2. **Update translations:**
   ```bash
   ./scripts/translate.sh update
   ```is no compilation step - QML is interpreted at runtime. The project uses simple scripts for installation and translation management.

## Installation

### Development Installation (Recommended)

For development and testing, install to your user directory:

```bash
./install.sh dev
```

This automatically removes any existing installation and installs the updated version.

### System-Wide Installation

For production use, install system-wide (requires root):

```bash
sudo ./install.sh system
```

This installs to `/usr/share/plasma/plasmoids/{PLASMOID_ID}/` where `{PLASMOID_ID}` is determined from your metadata.json file.

### Installation Management

```bash
./install.sh status     # Check what's installed
./install.sh uninstall  # Remove installation
```

## Translation Management

The plasmoid supports internationalization using KDE's i18n framework.

### Complete Translation Workflow

```bash
./scripts/translate.sh all
```

This extracts strings from QML files, updates existing translations, and compiles them.

### Step-by-Step Translation

#### Extract Translatable Strings

```bash
./scripts/translate.sh extract
```

This scans all QML files in `contents/` for `i18n()` calls and creates `po/{PLASMOID_ID}.pot` where `{PLASMOID_ID}` is determined from your metadata.json file.

#### Add a New Language

```bash
./scripts/translate.sh create es  # For Spanish
./scripts/translate.sh create fr  # For French
```

Edit the created `.po` file to add translations.

#### Update Existing Translations

```bash
./scripts/translate.sh update
```

This merges new strings from the template into existing `.po` files.

#### Compile Translations

```bash
./scripts/translate.sh compile
```

This creates `.mo` files from `.po` files for runtime use.

### Translation Statistics

```bash
./scripts/translate.sh stats
```

Shows completion status for each language.

## Development Workflow

**Making changes:**
```bash
# Edit your code, then apply changes:
./install.sh dev
```

This command automatically handles removing the old version and installing the new one.

### Translation Updates

When you add new `i18n()` calls:

1. **Extract new strings:**
   ```bash
   ./translate.sh extract
   ```
2. **Update translations:**
   ```bash
   ./translate.sh update
   ```
3. **Reinstall:**
   ```bash
   ./install.sh dev
   ```

## Directory Structure

```
├── contents/                # Plasmoid source files
│   ├── config/             # Configuration UI
│   └── ui/                 # Main UI components
├── po/                     # Translation files
│   ├── *.pot               # Translation template (generated)
│   ├── *.po                # Language-specific translations
│   └── *.mo                # Compiled translations (generated)
├── scripts/                # Utility scripts
│   ├── run-tests.sh        # Test runner
│   └── install-translations.sh  # Legacy translation installer
├── install.sh              # Installation script
├── scripts/translate.sh     # Translation management script
├── metadata.json           # Plasmoid metadata
└── tests/                  # QML unit tests
```

## Dependencies

### Runtime Dependencies
- KDE Plasma 6
- Qt 6
- Ollama (local or remote)

### Development Dependencies
- gettext tools (for translations)
- QML testing framework (for tests)

Install on Ubuntu/Debian:
```bash
sudo apt install gettext qml6-module-qttest
```

## Testing

Run the comprehensive test suite:

```bash
./scripts/run-tests.sh
```

## Troubleshooting

### Plasmoid Not Appearing

**After installation:**
```bash
# Restart Plasma
plasmashell --replace &
```

**Check installation:**
```bash
./install.sh status
kpackagetool6 --list | grep K-Ollama
```

### Translation Issues

**Strings not translating:**
- Ensure `i18n()` calls are in QML files
- Run `./scripts/translate.sh all` to update translations
- Reinstall with `./install.sh dev`

**New language not working:**
- Check that `.po` and `.mo` files exist in `po/`
- Verify language code is correct
- Restart Plasma after installation

## Contributing

1. **Fork and clone the repository**
2. **Set up development environment:**
   ```bash
   ./install.sh dev
   ```
3. **Make changes and test:**
   ```bash
   ./scripts/run-tests.sh
   ./install.sh dev
   ```
4. **Update translations if needed:**
   ```bash
   ./scripts/translate.sh all
   ```
5. **Submit a pull request**

### Code Style
- Follow existing QML/JavaScript patterns
- Use `i18n()` for user-visible strings
- Test your changes thoroughly