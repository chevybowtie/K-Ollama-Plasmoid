#!/bin/bash
set -euo pipefail

echo "=== Testing K-Ollama Plasmoid Spanish Translations ==="
echo

# Check if Spanish locale is available
if ! locale -a | grep -q "es_ES"; then
    echo "❌ Spanish locale not available. Run:"
    echo "   sudo locale-gen es_ES.UTF-8"
    echo "   sudo locale-gen"
    exit 1
fi

echo "✓ Spanish locale is available"

# Dynamically determine the plasmoid names from metadata.json
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PLASMOID_NAME=$(sed -n '/"KPlugin"/,/"Authors"/p' "$PROJECT_DIR/metadata.json" | grep '"Name"' | head -1 | sed 's/.*"Name": *"\([^"]*\)".*/\1/')
PLASMOID_ID=$(grep '"Id"' "$PROJECT_DIR/metadata.json" | sed 's/.*"Id": *"\([^"]*\)".*/\1/')

# Check if translations are installed
if [ ! -f "/usr/share/locale/es/LC_MESSAGES/${PLASMOID_NAME}.mo" ]; then
    echo "❌ Spanish translations not installed. Run:"
    echo "   ./build.sh install"
    exit 1
fi

echo "✓ Spanish translations are installed"

# Show translation statistics
echo
echo "=== Translation Statistics ==="
cd po && msgfmt --statistics es.po 2>&1 && cd ..

echo
echo "=== Available Testing Methods ==="
echo
echo "1. Test plasmashell with Spanish locale:"
echo "   LANG=es_ES.UTF-8 plasmashell --replace &"
echo
echo "2. Test KDE system settings with Spanish:"
echo "   LANG=es_ES.UTF-8 systemsettings5"
echo
echo "3. Test configuration dialog with Spanish:"
echo "   LANG=es_ES.UTF-8 plasmawindowed ${PLASMOID_ID}"
echo
echo "4. Check what translations you have:"
echo "   msgcat po/es.po | grep -A1 'msgstr \"[^\"]\'"
echo

echo "=== Current Spanish Translations ==="
msgcat po/es.po | grep -A1 'msgstr "[^"]' | sed 's/^msgid /English: /' | sed 's/^msgstr /Spanish: /'

echo
echo "💡 To see more translations in action:"
echo "   - Complete more entries in po/es.po"
echo "   - Run './build.sh build && ./build.sh install'"
echo "   - Restart plasmashell with Spanish locale"