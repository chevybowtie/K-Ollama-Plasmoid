# Changelog

All notable changes to K-Ollama are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.2.0] - 2026-05-27

### Added

- **Model info button** — new info button in the toolbar (visible when connected) fetches `/api/show` and `/api/ps` in parallel and appends a System message showing the selected model's architecture, quantization, capabilities, and all models currently loaded in memory with size, processor split, and unload time.

### Fixed

- **Polling pauses when widget is collapsed** — the connection status timer now stops while the widget is minimized to the taskbar, eliminating continuous background network requests. An immediate connectivity check fires when the widget is re-opened. Desktop widgets (always expanded) are unaffected.

---

## [1.1.0] - 2026-04-25

### Added

- **Per-code-block copy** — when markdown rendering is enabled, each fenced code block gets an icon-only copy button at its lower-left corner. Clicking it copies the code without fence markers or language tags.
- **Configurable response timeout** — new spinner in Settings → Behavior sets the maximum time to wait for a streaming response. Set to 0 to disable the timeout entirely. Useful for large models that generate long responses.
- **Inline error banners** — network failures and timeout errors are now shown as a dismissible inline banner directly in the chat area instead of requiring log inspection.
- **Separate Appearance and Behavior tabs** — the single configuration tab has been split into dedicated Appearance and Behavior tabs for easier navigation.
- **System prompt support** — optional system message that is prepended to every API request (Settings → Server). Disabled by default.
- **Temperature control** — slider in Settings → Server to tune response creativity (0.0–2.0).
- **Sound notification** — optional beep when an AI response completes (Settings → Behavior).
- **Debug logging toggle** — enable/disable `console.log` output from the widget without restarting Plasma (Settings → Behavior).
- **Localization** — added translations for German, French, Italian, Portuguese (BR), Russian, Chinese (Simplified), Japanese, Korean, and Arabic. Spanish translation updated. 11 languages total including English.
- **Mouse text selection in input field** — the message input area now supports click-drag selection, double-click word selection, and right-click context menu.

### Changed

- Markdown rendering is now segmented: text and code blocks are rendered as separate visual sections, allowing UI elements to be placed adjacent to code rather than below the full message.
- Code block background uses a subtle dark tint with a 1 px border to clearly delineate block boundaries.
- Conversation history is now trimmed to stay within a configurable limit, with UI list and prompt array kept in sync.

### Fixed

- Message delete index misalignment after history trim.
- Packaging script `unzip -l` verification was looking in the wrong directory.
- QML lint import version inconsistencies across test files.
- Three failing markdown rendering tests caused by Qt `TextArea.MarkdownText` round-trip normalization adding trailing newlines.

### Infrastructure

- GitHub Actions release workflow updated: `upload-artifact` v3 → v4, `action-gh-release` v1 → v2, Node.js 24 opt-in via `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24`.
- Package name now derived from `KPlugin.Name` via `jq`, matching the local `package-up.sh` output (`K-Ollama-1.1.0.plasmoid`).

---

## [1.0.0] - 2025

### Added

- Initial release with full KDE Plasma 6 compatibility using `PlasmoidItem` architecture.
- Multi-model support — switch between any Ollama model from a dropdown.
- Real-time streaming responses via XMLHttpRequest.
- Persistent configuration: server URL, selected model, pin state, and all settings survive restarts.
- Configurable input modes: classic (Ctrl+Enter to send) and modern (Enter to send).
- Optional markdown rendering for AI responses.
- One-click copy of full AI responses.
- Pin-to-stay-open button (panel mode).
- Multiple icon themes: adaptive, filled, outlined in light and dark variants.
- Remote Ollama server support.
- Spanish localization.
- Comprehensive QML unit test suite.
- GitHub Actions workflow for automated `.plasmoid` package builds on release tags.
