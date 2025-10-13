#!/bin/bash
# K-Ollama Plasmoid Packaging Script
# Creates a clean .plasmoid package for KDE Store distribution

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
PLUGIN_ID=$(grep '"Id"' "$PROJECT_DIR/metadata.json" | sed 's/.*"Id": *"\([^"]*\)".*/\1/')
APP_NAME=$(grep '"Name"' "$PROJECT_DIR/metadata.json" | sed 's/.*"Name": *"\([^"]*\)".*/\1/')
VERSION=$(grep '"Version"' "$PROJECT_DIR/metadata.json" | sed 's/.*"Version": *"\([^"]*\)".*/\1/')
PACKAGE_NAME="${APP_NAME}-${VERSION}.plasmoid"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 K-Ollama Plasmoid Packaging Script${NC}"
echo -e "Project Dir: ${PROJECT_NAME}"
echo -e "Plugin ID: ${PLUGIN_ID}"
echo -e "App Name: ${APP_NAME}"
echo -e "Version: ${YELLOW}${VERSION}${NC}"
echo -e "Package: ${YELLOW}${PACKAGE_NAME}${NC}"
echo ""

# Change to parent directory for packaging
cd "$(dirname "$PROJECT_DIR")"
echo -e "${BLUE}Working directory:${NC} $(pwd)"

# Remove existing package if it exists
if [ -f "$PACKAGE_NAME" ]; then
    echo -e "${YELLOW}Removing existing package:${NC} $PACKAGE_NAME"
    rm -f "$PACKAGE_NAME"
fi

echo -e "${BLUE}Creating package with essential files only...${NC}"

# Create the package by explicitly including only what end users need
zip -r "$PACKAGE_NAME" \
    "$PROJECT_NAME/metadata.json" \
    "$PROJECT_NAME/LICENSE" \
    "$PROJECT_NAME/README.md" \
    "$PROJECT_NAME/contents/" \
    "$PROJECT_NAME/po/"

# Check if package was created successfully
if [ -f "$PACKAGE_NAME" ]; then
    PACKAGE_SIZE=$(du -h "$PACKAGE_NAME" | cut -f1)
    echo ""
    echo -e "${GREEN}✅ Package created successfully!${NC}"
    echo -e "File: ${YELLOW}$PACKAGE_NAME${NC}"
    echo -e "Size: ${YELLOW}$PACKAGE_SIZE${NC}"
    echo ""
    
    # Show what's included (first few items)
    echo -e "${BLUE}Package contents (sample):${NC}"
    unzip -l "$PACKAGE_NAME" | head -15
    
    echo ""
    echo -e "${BLUE}Included files (end-user essentials only):${NC}"
    echo -e "• ${GREEN}metadata.json${NC} (widget metadata)"
    echo -e "• ${GREEN}LICENSE${NC} (legal requirement)"
    echo -e "• ${GREEN}README.md${NC} (user documentation)"
    echo -e "• ${GREEN}contents/${NC} (widget UI, config, assets, images)"
    echo -e "• ${GREEN}po/${NC} (translations)"
    echo ""
    echo -e "${BLUE}Auto-excluded (everything else):${NC}"
    echo -e "• Development files, scripts, tests, build artifacts"
    echo -e "• Version control, hidden files, contributor docs"
    
    echo ""
    echo -e "${GREEN}🎯 Ready for KDE Store upload!${NC}"
    echo -e "Location: ${YELLOW}$(pwd)/$PACKAGE_NAME${NC}"
    
else
    echo -e "${RED}❌ Package creation failed!${NC}"
    exit 1
fi