# KDE Store Upload Materials for K-Ollama Plasmoid

## Basic Information ✅
- **Title**: K-Ollama
- **Version**: 1.0.0 (matches metadata.json)
- **License**: LGPL-2.1-or-later
- **Website**: https://github.com/chevybowtie/K-Ollama-Plasmoid
- **Authors**: Denys Madureira, Paul Sturm

## Category Selection ✅
- **Main Category**: KDE Plasma Extensions
- **Sub-Category**: Plasma 6
- **Specific Category**: Applets/Widgets

## Short Description ✅
Ollama client with modern Plasma 6 compatibility

## Long Description ✅
A modern KDE Plasma widget for chatting with your local or remote Ollama AI models. Features a clean interface, persistent settings, configurable input behavior, and robust error handling.

**Key Features:**
• Multi-Model Support - Switch between all your Ollama models
• Persistent Settings - Remembers your configuration across sessions  
• Configurable Input - Enter-to-send or Ctrl+Enter-to-send modes
• Markdown Rendering - Optional markdown formatting in AI responses
• Pin Widget - Keep chat open while working (panel mode only)
• Multiple Themes - Adaptive, filled, outlined icons (light/dark)
• Remote Servers - Connect to Ollama on other machines
• Copy Messages - One-click copying of AI responses
• Optimized Streaming - Real-time responses without UI blocking

**Requirements:**
- KDE Plasma 6
- Ollama running locally or remotely (ollama.ai)

Based on Denys Madureira's original code, modernized for KDE Plasma 6.

## Changelog for v1.0.0 ✅
Initial release of K-Ollama Plasmoid with full KDE Plasma 6 compatibility.

**New Features:**
- Complete Plasma 6 port with modern PlasmoidItem architecture
- Enhanced Ollama client with persistent configuration
- Configurable input modes (Enter vs Ctrl+Enter to send)
- Optional markdown rendering for AI responses
- Multiple icon themes (adaptive, filled, outlined for light/dark)
- Remote server support for distributed Ollama setups
- One-click message copying functionality
- Optimized streaming for real-time responses
- Comprehensive error handling and connection management
- Internationalization support (Spanish included)

**Technical Improvements:**
- Modern QML architecture using PlasmoidItem
- Proper SPDX license formatting
- KDE Store compliant package structure
- Comprehensive test suite
- Build system with CMake integration

## Files Ready for Upload ✅
- **Package File**: `K-Ollama-Plasmoid-1.0.0.plasmoid` (64KB)
- **Package Location**: `/home/paul/projects/K-Ollama-Plasmoid-1.0.0.plasmoid`
- **Package Tested**: ✅ Successfully installs via kpackagetool6
- **Package Generated**: Use `./scripts/package-up.sh` to create clean builds

## Package Contents (End-User Only) ✅
- `metadata.json` - Widget metadata
- `LICENSE` - Legal requirement
- `README.md` - User documentation
- `contents/` - Complete widget (UI, config, assets, images)
- `po/` - Translation files

## Screenshots Needed 📸
You'll need to take screenshots showing:

1. **Main Interface**: The plasmoid in action with a chat conversation
2. **Configuration Panel**: Settings dialog showing server configuration
3. **Panel Integration**: Widget in the KDE panel (compact mode)
4. **Themes**: Different icon themes if possible
5. **Features Demo**: Showing key features like model selection, markdown rendering, etc.

**Screenshot Tips:**
- Use high resolution (at least 1024px wide)
- Show the widget in actual use with realistic content
- Include context (desktop/panel environment)
- PNG or JPG format
- At least 1 screenshot required, 3-5 recommended

## Upload Checklist 📋
- [ ] Log into store.kde.org (OpenDesktop account)
- [ ] Navigate to "My Products" → "Add"
- [ ] Upload K-Ollama-Plasmoid-1.0.0.plasmoid file
- [ ] Select category: KDE Plasma Extensions → Plasma 6 → Applets/Widgets
- [ ] Fill in title: "K-Ollama"
- [ ] Add short description (from above)
- [ ] Add long description (from above)
- [ ] Add changelog (from above)
- [ ] Upload screenshots
- [ ] Set license to LGPL-2.1-or-later
- [ ] Add homepage link: https://github.com/chevybowtie/K-Ollama-Plasmoid
- [ ] Review and submit

## KDE Store URLs 🔗
- **Main Store**: https://store.kde.org
- **Login**: https://store.kde.org (uses OpenDesktop account)
- **Browse Plasma 6**: https://store.kde.org/browse/cat/710/
- **Upload New**: My Products → Add (after login)

## Post-Upload Process 📝
1. **Immediate**: Widget appears on KDE Store website
2. **Cache Refresh**: Widget appears in Plasma's "Get New Widgets" (may take time)
3. **User Installation**: Add Widgets → Get New Widgets → Download New Plasma Widgets
4. **Updates**: Bump version in metadata.json, run package script, upload as "New Version"

## Future Updates 🔄
1. Update version in `metadata.json`
2. Run `./scripts/package-up.sh` to create new package
3. Upload new version on KDE Store product page
4. Add changelog describing changes
5. Keep same plugin ID for automatic update notifications

## Troubleshooting 🔧
- **Not visible in "Get New Widgets"**: Check category (must be Plasma 6) or missing API version
- **Installation fails**: Verify package structure with `unzip -l filename.plasmoid`
- **Legacy issues**: Ensure no old .desktop files, proper PlasmoidItem usage
- **Package problems**: Test locally with `kpackagetool6 --install` before uploading