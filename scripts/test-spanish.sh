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

# Check if translations are installed
if [ ! -f "/usr/share/locale/es/LC_MESSAGES/K-Ollama-Plasmoid.mo" ]; then
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
echo "   LANG=es_ES.UTF-8 plasmawindowed org.kde.K-Ollama-Plasmoid"
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