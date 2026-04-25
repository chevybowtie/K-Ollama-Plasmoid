## Plan: K-Ollama v1.1 UX + Stability

Deliver v1.1 as a UX-first release focused on copy/paste and markdown usability while including low-risk, high-value stability/performance fixes. Keep behavior Plasma 6-native, avoid broad architecture rewrites, and preserve current user workflows.

---

### Phase A — Baseline and guardrails *(blocks all subsequent phases)*

- **Fix test/production structure mismatch first**: `tst_markdown.qml` wraps its markdown `TextArea` in a `ScrollView`, but `main.qml` uses a bare `TextArea` — align the test fixture to match production before extending any tests.
- Extend `tests/tst_markdown.qml` with targeted cases: full-message copy in markdown mode, code-fence parsing edge cases.
- Extend `tests/tst_ui_input.qml` with targeted cases: message-history trimming synchronization, keyboard/copy interaction.

### Phase B — Copy/paste UX (core v1.1 scope)

- Keep existing top-level Copy button semantics (copy full rendered message) and improve reliability/feedback.
- Add copy success feedback (toast/inline transient status) to remove ambiguity after clicks.
- Add per-code-block copy affordance for fenced code blocks in markdown messages.
- Ensure per-code-block copy strips markdown fences/language tags and copies clean code.
- Preserve text selection ergonomics (no regressions to `selectByMouse` or keyboard navigation).
- Add optional keyboard shortcut handling for copy while message card is focused, without overriding normal text-edit behavior in input field.

### Phase C — Performance/stability quick wins

- Keep model/context and visible transcript trimming in sync to avoid divergent memory growth and list-model mismatch.
- Fix `deleteMessage` index alignment: it uses `listModel` index to splice `promptArray`, but the two can drift after a trim event — the fix must cover `deleteMessage` as well as the append path.
- Reduce expensive markdown delegate churn by preventing full delegate teardown where possible when markdown setting flips.
- Tighten streaming update path to avoid repeated heavy parsing on every `readystatechange` burst (incremental line buffering + throttled UI updates).
- ~~Fix streaming XHR timeout~~ **Done**: replaced hardcoded 30 s `xhr.timeout` with a user-configurable `streamingTimeoutSecs` setting (0 = no limit, default); exposed in the new Behavior config page.
- Improve timeout/error visibility for request failures so users can distinguish timeout/network/server states.

### Phase D — Localization, KDE6, and future-proof cleanup

- Add localization for top 10 languages using existing `po/` infrastructure.
- Convert remaining version-pinned QtQuick import in `ConnectionManager.qml` to Qt6-style generic import.
- Align test imports with Qt6-style generic modules where safe.
- Refresh README wording to clearly state Plasma 6/Qt6 support path and reduce Qt5-era ambiguity.

### Phase E — Release prep

- Run `scripts/run-tests.sh` and ensure all existing + new tests pass.
- Bump version in `metadata.json` from `1.0.1` to `1.1.0`.
- Run packaging script and verify artifact integrity for Plasma 6 install.
- Manually validate copy flows:
  - Full-message copy in markdown mode returns readable full message.
  - Per-code-block copy returns code only (no fences).
  - Hover/visibility and keyboard copy behavior are discoverable and non-disruptive.
- Stress test long conversations (>100 exchanges) and confirm memory/UI remain responsive and history trimming stays synchronized.
- Toggle markdown enable/disable during a session and verify no major UI stalls or lost content.
- Verify connection timeout/error states are visible and actionable.
- Update changelog with copy UX improvements, localization, behavior clarifications, and compatibility notes.
- Submit updated package to KDE Store.

---

**Relevant files**
- `contents/ui/main.qml` — message delegate, markdown/plain loaders, copy button behavior, request flow, history trimming logic
- `contents/js/utils.js` — markdown/code-block parsing helpers and copy extraction utilities
- `contents/ui/ConnectionManager.qml` — Qt import modernizing and polling/timeout behavior cleanup
- `tests/tst_markdown.qml` — extend with markdown/copy behavior tests (file exists)
- `tests/tst_ui_input.qml` — extend with keyboard/copy interaction tests (file exists)
- `tests/tst_performance.qml` — streaming/history performance regression checks (file exists)
- `po/` — localization files for i18n
- `README.md` — compatibility and behavior documentation updates
- `metadata.json` — version bump to 1.1.0

**Decisions**
- Scope: UX-first v1.1, not broad architecture rewrite.
- History policy: Trim both memory context and visible UI transcript.
- Default markdown Copy behavior: Keep full-message copy; add per-code-block copy controls.
- Per-code-block copy button: Always visible on code blocks (not hover-only) to maximize discoverability.
- Localization: Include top 10 languages in v1.1 using existing `po/` infrastructure.
- Excluded from v1.1: full syntax highlighting engine for code fences, transcript export/archive system, major backend/C++ migration.

**Further Considerations**
- Decide whether to include retry/backoff in v1.1 or defer; recommendation: include minimal single-retry timeout handling only.
- Consider adding an explicit max-history setting in config for v1.2 after observing real-world usage telemetry/feedback.
