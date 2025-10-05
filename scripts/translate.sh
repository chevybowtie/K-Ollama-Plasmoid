#!/bin/bash

# Translation management script for K-Ollama-Plasmoid
# Handles extraction, updating, and compilation of translations

set -e  # Exit on any error

PROJECT_NAME="K-Ollama-Plasmoid"
POT_FILE="po/${PROJECT_NAME}.pot"

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

# Function to check if gettext tools are available
check_dependencies() {
    local missing_deps=()

    if ! command -v xgettext &> /dev/null; then
        missing_deps+=("xgettext")
    fi

    if ! command -v msgfmt &> /dev/null; then
        missing_deps+=("msgfmt")
    fi

    if ! command -v msgmerge &> /dev/null; then
        missing_deps+=("msgmerge")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing gettext tools: ${missing_deps[*]}"
        echo
        echo "Install gettext tools:"
        echo "  Ubuntu/Debian: sudo apt install gettext"
        echo "  Fedora: sudo dnf install gettext"
        echo "  Arch: sudo pacman -S gettext"
        echo "  macOS: brew install gettext"
        exit 1
    fi
}

# Function to extract translatable strings from QML files
extract_messages() {
    print_step "Extracting translatable messages from QML files..."

    check_dependencies

    # Create po directory if it doesn't exist
    mkdir -p po

    # Find all QML files
    QML_FILES=$(find contents -name "*.qml" -type f)

    if [ -z "$QML_FILES" ]; then
        print_warning "No QML files found in contents/ directory"
        return 1
    fi

    # Extract messages using xgettext
    xgettext \
        --language=JavaScript \
        --keyword=i18n \
        --keyword=i18nc:1c,2 \
        --keyword=i18np:1,2 \
        --keyword=i18ncp:1c,2,3 \
        --from-code=UTF-8 \
        --output="${POT_FILE}" \
        --package-name="${PROJECT_NAME}" \
        --package-version="1.0.0" \
        --msgid-bugs-address="https://github.com/chevybowtie/K-Ollama-Plasmoid" \
        $QML_FILES

    if [ $? -eq 0 ]; then
        print_success "Messages extracted to ${POT_FILE}"
        echo "Found $(grep -c '^msgid "' "${POT_FILE}" 2>/dev/null || echo 0) translatable strings"
    else
        print_error "Failed to extract messages"
        return 1
    fi
}

# Function to update existing translation files
update_translations() {
    print_step "Updating existing translation files..."

    if [ ! -f "${POT_FILE}" ]; then
        print_error "Template file ${POT_FILE} not found. Run 'extract' first."
        return 1
    fi

    local updated_count=0

    # Find all .po files
    for po_file in po/*.po; do
        if [ -f "$po_file" ]; then
            lang=$(basename "$po_file" .po)
            print_step "Updating ${lang}.po..."

            msgmerge \
                --update \
                --backup=none \
                --no-fuzzy-matching \
                "$po_file" \
                "${POT_FILE}"

            if [ $? -eq 0 ]; then
                print_success "Updated ${lang}.po"
                ((updated_count++))
            else
                print_error "Failed to update ${lang}.po"
            fi
        fi
    done

    if [ $updated_count -eq 0 ]; then
        print_warning "No .po files found to update"
    else
        print_success "Updated $updated_count translation file(s)"
    fi
}

# Function to compile .po files to .mo files
compile_translations() {
    print_step "Compiling translation files..."

    local compiled_count=0

    # Find all .po files
    for po_file in po/*.po; do
        if [ -f "$po_file" ]; then
            lang=$(basename "$po_file" .po)
            mo_file="po/${lang}.mo"

            print_step "Compiling ${lang}.po..."

            msgfmt \
                --output-file="${mo_file}" \
                "$po_file"

            if [ $? -eq 0 ]; then
                print_success "Compiled ${lang}.mo"
                ((compiled_count++))
            else
                print_error "Failed to compile ${lang}.po"
            fi
        fi
    done

    if [ $compiled_count -eq 0 ]; then
        print_warning "No .po files found to compile"
    else
        print_success "Compiled $compiled_count translation file(s)"
    fi
}

# Function to create a new translation file
create_translation() {
    local lang_code="$1"

    if [ -z "$lang_code" ]; then
        print_error "Language code required. Usage: $0 create <lang_code>"
        echo "Examples: $0 create es (Spanish), $0 create fr (French)"
        return 1
    fi

    if [ ! -f "${POT_FILE}" ]; then
        print_error "Template file ${POT_FILE} not found. Run 'extract' first."
        return 1
    fi

    local po_file="po/${lang_code}.po"

    if [ -f "$po_file" ]; then
        print_warning "${po_file} already exists. Use 'update' to update it instead."
        return 1
    fi

    print_step "Creating ${lang_code}.po..."

    msginit \
        --input="${POT_FILE}" \
        --output-file="$po_file" \
        --locale="${lang_code}"

    if [ $? -eq 0 ]; then
        print_success "Created ${po_file}"
        print_warning "Edit ${po_file} to add translations, then run 'compile'"
    else
        print_error "Failed to create ${po_file}"
        return 1
    fi
}

# Function to show translation statistics
stats() {
    print_step "Translation statistics..."

    if [ ! -f "${POT_FILE}" ]; then
        print_warning "No template file found. Run 'extract' first."
        return 1
    fi

    echo
    echo "Template (${POT_FILE}):"
    local total_strings=$(grep -c '^msgid "' "${POT_FILE}" 2>/dev/null || echo 0)
    echo "  Total strings: $total_strings"

    echo
    echo "Translation files:"
    for po_file in po/*.po; do
        if [ -f "$po_file" ]; then
            lang=$(basename "$po_file" .po)

            # Get translation statistics
            local stats_output=$(msgfmt --statistics "$po_file" 2>&1)
            local translated=$(echo "$stats_output" | grep -o '[0-9]\+ translated' | grep -o '[0-9]\+' | head -1 || echo 0)
            local fuzzy=$(echo "$stats_output" | grep -o '[0-9]\+ fuzzy' | grep -o '[0-9]\+' | head -1 || echo 0)
            local untranslated=$(echo "$stats_output" | grep -o '[0-9]\+ untranslated' | grep -o '[0-9]\+' | head -1 || echo 0)

            # Calculate percentage
            local percent=0
            if [ "$total_strings" -gt 0 ] 2>/dev/null && [ "$translated" -gt 0 ] 2>/dev/null; then
                percent=$(( (translated * 100) / total_strings ))
            fi

            printf "  %s: %d/%d (%d%%) - %d fuzzy, %d untranslated\n" \
                   "$lang" "$translated" "$total_strings" "$percent" "$fuzzy" "$untranslated"
        fi
    done
}

# Function to clean translation artifacts
clean() {
    print_step "Cleaning translation artifacts..."

    local cleaned=false

    # Remove compiled .mo files
    if ls po/*.mo 1> /dev/null 2>&1; then
        rm po/*.mo
        print_success "Removed compiled .mo files"
        cleaned=true
    fi

    # Remove template file
    if [ -f "${POT_FILE}" ]; then
        rm "${POT_FILE}"
        print_success "Removed template file"
        cleaned=true
    fi

    if [ "$cleaned" = false ]; then
        print_warning "Nothing to clean"
    fi
}

# Function to show usage
usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  extract    Extract translatable strings from QML files"
    echo "  update     Update existing .po files from template"
    echo "  compile    Compile .po files to .mo files"
    echo "  create     Create new translation file (requires language code)"
    echo "  all        Extract, update, and compile all translations"
    echo "  stats      Show translation completion statistics"
    echo "  clean      Remove compiled .mo files and template"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 extract                    # Extract messages from QML"
    echo "  $0 create es                  # Create Spanish translation"
    echo "  $0 all                        # Complete translation workflow"
    echo "  $0 stats                      # Show completion status"
}

# Main script logic
case "${1:-help}" in
    extract|pot)
        extract_messages
        ;;
    update|merge)
        update_translations
        ;;
    compile|mo)
        compile_translations
        ;;
    create|new)
        create_translation "$2"
        ;;
    all|full)
        extract_messages
        update_translations
        compile_translations
        ;;
    stats|status)
        stats
        ;;
    clean)
        clean
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