# Development Guide

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
  - [Development Installation](#development-installation-recommended)
  - [System-Wide Installation](#system-wide-installation)
  - [Installation Management](#installation-management)
- [Development Workflow](#development-workflow)
  - [Adding New i18n Strings](#adding-new-i18n-strings)
- [Translation Management](#translation-management)
  - [Complete Translation Workflow](#complete-translation-workflow)
  - [Step-by-Step Translation](#step-by-step-translation)
  - [Translation Troubleshooting](#translation-troubleshooting)
- [Packaging](#packaging)
- [Directory Structure](#directory-structure)
- [Dependencies](#dependencies)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Overview

This is a KDE Plasma 6 plasmoid written entirely in QML and JavaScript. There is no compilation step — QML is interpreted at runtime by Plasma. The project uses simple shell scripts for installation, translation management, packaging, and testing.

## Installation

### Development Installation (Recommended)

For development and testing, install to your user directory:

```bash
./install.sh dev
```

This automatically removes any existing installation and installs the updated version. No restart is needed for most QML changes — just remove and re-add the widget, or run the command again.

### System-Wide Installation

For production use, install system-wide (requires root):

```bash
sudo ./install.sh system
```

This installs to `/usr/share/plasma/plasmoids/{PLASMOID_ID}/` where `{PLASMOID_ID}` is read from `metadata.json`.

### Installation Management

```bash
./install.sh status     # Check what's installed and where
./install.sh uninstall  # Remove user-level installation
```

## Development Workflow

**Making changes:**

```bash
# Edit your code, then apply changes:
./install.sh dev
```

This removes the old installation and installs the updated version in one step.

**Running tests:**

```bash
./scripts/run-tests.sh
```

### Adding New i18n Strings

When you add new `i18n()` calls to QML files:

1. **Extract new strings:**

   ```bash
   ./scripts/translate.sh extract
   ```

2. **Merge into existing translations:**

   ```bash
   ./scripts/translate.sh update
   ```

3. **Compile and reinstall:**

   ```bash
   ./scripts/translate.sh compile
   ./install.sh dev
   ```

Or run all three steps at once:

```bash
./scripts/translate.sh all
```

## Translation Management

The plasmoid supports internationalization using KDE's i18n framework. Translatable strings use `i18n()` or `i18nc()` in QML files.

Currently supported languages: English (source), Spanish, German, French, Italian, Portuguese (BR), Russian, Chinese (Simplified), Japanese, Korean, Arabic.

### Complete Translation Workflow

```bash
./scripts/translate.sh all
```

Extracts strings from QML files, merges new strings into all existing `.po` files, and compiles `.mo` binaries.

### Step-by-Step Translation

#### Extract Translatable Strings

```bash
./scripts/translate.sh extract
```

Scans all QML files in `contents/` for `i18n()`/`i18nc()` calls and writes `po/K-Ollama-Plasmoid.pot`.

#### Add a New Language

```bash
./scripts/translate.sh create es  # Spanish
./scripts/translate.sh create fr  # French
```

This creates a new `.po` file pre-populated from the `.pot` template. Open it in a text editor or a PO editor (e.g. Lokalize, Poedit) and fill in the `msgstr` fields.

#### Update Existing Translations

```bash
./scripts/translate.sh update
```

Merges new or changed source strings from the `.pot` template into all existing `.po` files. Strings that changed in English are marked `fuzzy` so translators can review them.

#### Compile Translations

```bash
./scripts/translate.sh compile
```

Creates binary `.mo` files from `.po` files. These are what Plasma loads at runtime. Always compile before reinstalling if you've edited translations.

#### Translation Statistics

```bash
./scripts/translate.sh stats
```

Shows per-language completion percentage (translated / total strings).

### Translation Troubleshooting

**Strings not translating at runtime:**

- Ensure the string uses `i18n()` in the QML source.
- Run `./scripts/translate.sh all` to regenerate and compile.
- Reinstall with `./install.sh dev` and restart Plasma (`plasmashell --replace &`).

**New language not appearing:**

- Confirm both a `.po` and a compiled `.mo` file exist in `po/`.
- Verify the language code matches what your system locale expects (e.g. `pt_BR`, not `pt-BR`).

## Packaging

To build a `.plasmoid` file for distribution (e.g. KDE Store upload):

```bash
./scripts/package-up.sh
```

This reads the version from `metadata.json`, creates `K-Ollama-{VERSION}.plasmoid` in the **parent** directory of the project, and prints a contents summary. The package includes only end-user files (`metadata.json`, `LICENSE`, `README.md`, `contents/`, `po/`) — development files, tests, and scripts are excluded.

Before packaging:

1. Bump `"Version"` in `metadata.json`.
2. Run `./scripts/translate.sh all` to ensure compiled `.mo` files are up to date.
3. Run `./scripts/package-up.sh`.

## Directory Structure

```txt
├── contents/                    # Plasmoid source files
│   ├── config/                  # KCM configuration pages
│   │   ├── config.qml           # Declares config tabs (Server, Appearance, Behavior)
│   │   └── main.xml             # KConfig schema (persisted settings)
│   ├── js/                      # Shared JavaScript utilities
│   │   └── utils.js             # getServerUrl, extractCodeBlocks, debugLog, etc.
│   └── ui/                      # Main UI components
│       ├── main.qml             # Primary widget UI and Ollama API logic
│       ├── ConfigAppearance.qml # Icon theme selection
│       ├── ConfigBehavior.qml   # Input, sound, markdown, timeout, debug settings
│       ├── ConfigServer.qml     # Server URL, temperature, system prompt
│       ├── ConfigDefaults.qml   # Default values for all cfg_ properties
│       ├── CompactRepresentation.qml  # Panel icon
│       ├── ConnectionManager.qml      # Polls server and exposes connected/status
│       └── assets/              # Icons and audio
├── po/                          # Translation files
│   ├── *.pot                    # Translation template (generated by extract)
│   ├── *.po                     # Language-specific translations (human-edited)
│   └── *.mo                     # Compiled translations (generated by compile)
├── scripts/                     # Utility scripts
│   ├── translate.sh             # Translation management (extract/update/compile/stats)
│   ├── package-up.sh            # Build .plasmoid distribution package
│   ├── run-tests.sh             # QML unit test runner
│   └── install-translations.sh  # Low-level helper called by install.sh
├── tests/                       # QML unit tests (qmltestrunner)
├── docs/                        # Project documentation
├── install.sh                   # Install/uninstall/status script
└── metadata.json                # Plasmoid identity, version, and KDE metadata
```

## Dependencies

### Runtime Dependencies

- KDE Plasma 6
- Qt 6
- Ollama running locally or remotely

### Development Dependencies

- `gettext` — for `xgettext`, `msgmerge`, `msgfmt` (translation toolchain)
- `jq` — used by `package-up.sh` to read `metadata.json`
- Qt6 QML test framework — for running unit tests

Install on Debian/Ubuntu:

```bash
sudo apt install gettext jq qml6-module-qttest libqt6quicktest6
```

## Testing

Run the full test suite:

```bash
./scripts/run-tests.sh
```

**Options:**

```bash
./scripts/run-tests.sh -v2           # Verbose output (shows individual test names)
SKIP_QML_LINT=1 ./scripts/run-tests.sh   # Skip QML linting for faster iteration
QMLTEST_RUNNER=/path/to/qmltestrunner ./scripts/run-tests.sh  # Custom runner path
```

Tests live in `tests/` and use Qt's `qmltestrunner`. Each file covers a distinct area: utilities, UI input behavior, markdown rendering, server connection, KCM config, error handling, and performance.

## Troubleshooting

### Plasmoid Not Appearing After Installation

```bash
plasmashell --replace &          # Restart Plasma
./install.sh status              # Verify installation path
kpackagetool6 --list | grep K-Ollama  # Confirm KDE sees it
```

### Changes Not Taking Effect

KDE caches plasmoid packages. After `./install.sh dev`, remove and re-add the widget from the panel, or restart Plasma with `plasmashell --replace &`.

## Contributing

1. Fork the repository and clone your fork.
2. Install for development: `./install.sh dev`
3. Make changes and run tests: `./scripts/run-tests.sh`
4. Apply changes to the running widget: `./install.sh dev`
5. If you added `i18n()` strings: `./scripts/translate.sh all`
6. Submit a pull request.

### Code Style

- Use `i18n()` for all user-visible strings; `i18nc()` when context is needed for disambiguation.
- Follow existing QML/JavaScript patterns — no version numbers on Qt imports (`import QtQuick`, not `import QtQuick 2.15`).
- Default to no comments; add one only when the *why* is non-obvious.
