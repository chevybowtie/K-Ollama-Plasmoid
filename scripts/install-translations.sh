#!/bin/bash

# Install translations for K-Ollama-Plasmoid
# Usage: sudo ./install-translations.sh

PLASMOID_NAME="K-Ollama-Plasmoid"
LOCALE_DIR="/usr/share/locale"

# Create locale directories and install translations
for po_file in po/*.po; do
    if [ -f "$po_file" ]; then
        # Extract language code (e.g., es from es.po)
        lang=$(basename "$po_file" .po)
        
        # Create directory structure
        mkdir -p "$LOCALE_DIR/$lang/LC_MESSAGES"
        
        # Compile and install
        msgfmt "$po_file" -o "$LOCALE_DIR/$lang/LC_MESSAGES/$PLASMOID_NAME.mo"
        
        echo "Installed translation for $lang"
    fi
done

echo "Translation installation complete!"
echo "Restart Plasma to see translations: systemctl --user restart plasma-plasmashell"