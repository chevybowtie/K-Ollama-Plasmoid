KCM / cfg_* pattern (developer notes)

Summary
-------
This short document explains the "KCM pattern" used in this plasmoid's configuration pages. It's targeted at contributors and code-completion assistants (like Copilot) so new options follow the same UX and wiring.

Goals
-----
- Make settings pages behave consistently with KDE's Apply/Cancel model.
- Keep UI controls testable and single-sourced.
- Preserve separation between the KCM UI and persistent `Plasmoid.configuration` until the user applies changes.

Pattern
-------
1. Expose editable settings as properties named `cfg_<name>` on the top-level KCM component (usually `KCM.SimpleKCM`).
   - Use `property` or `property alias` to connect the UI control to the `cfg_*` property.
   - Example: `property alias cfg_debugLogs: debugLogsCheckbox.checked`

2. Bind controls to `cfg_*` rather than writing directly to `Plasmoid.configuration` in their change handlers.
   - Example:
     CheckBox {
         id: debugLogsCheckbox
         checked: cfg_debugLogs
     }

3. Let the KCM framework handle Apply/Cancel.
   - When Apply is pressed, the KCM host will read `cfg_*` properties and persist them into the plasmoid `configuration` object.
   - If you instead write directly to `Plasmoid.configuration` from the control, you bypass Apply/Cancel and the page will not behave as a standard KCM.

4. Provide `cfg_<name>Default` properties as needed.
   - The KConfig system sometimes sends default/value-applier variants; the existing codebase already declares these for many settings. Follow the pattern if necessary.

Testing notes
--------------
- Unit tests (QML tests) should not rely on writing directly to `Plasmoid.configuration` when testing KCM pages. Test the helpers and UI logic independently.
- To test persistence behavior manually: toggle a cfg_* control in the KCM UI, press Apply, then inspect `Plasmoid.configuration.<name>` in the plasmoid runtime (or test via `plasmoidviewer`).

When to write directly to `Plasmoid.configuration`
-------------------------------------------------
- If you want immediate persistence (no Apply/Cancel), it's acceptable to write to `Plasmoid.configuration` in the control's change handlers. This is a deliberate UX decision — avoid doing so if you want the standard KCM Apply/Cancel experience.

Example
-------
KCM side (`ConfigAppearance.qml`):

KCM.SimpleKCM {
    property alias cfg_debugLogs: debugLogsCheckbox.checked

    CheckBox {
        id: debugLogsCheckbox
        text: i18nc("@option:check", "Enable debug console logs")
        checked: cfg_debugLogs
    }
}

The KCM host will persist `cfg_debugLogs` into the plasmoid configuration when the user clicks Apply.

Notes for copilot / code assistants
----------------------------------
- When adding new settings, prefer `cfg_*` properties and aliases so the KCM host detects changes.
- Avoid introducing direct writes to `Plasmoid.configuration` unless the setting is intentionally immediate.
- Keep the UI bindings declarative and side-effect-free where possible to simplify testing.
- The developer PC probably only uses Python 3. Ensure any scripts or tools used in the development workflow are compatible with Python 3.

Additional patterns and conventions
----------------------------------
These are practical guidelines for contributors and code assistants to keep the codebase consistent and maintainable.

1) Core architecture & file layout
   - UI components: `contents/ui/*.qml` (one component per file, single responsibility)
   - Pure helpers: `contents/js/utils.js` (stateless functions used by both runtime and tests)
   - Tests: `tests/tst_*.qml` import the JS helpers directly
   - Keep business logic (network, parsing, normalizing) in JS helpers where possible to make testing easy.

2) JS helpers & testability
   - Helpers in `contents/js/utils.js` should avoid referencing `Plasmoid` directly. Accept inputs and return outputs.
   - For helpers that must touch runtime state, provide a clear API and small wrappers for QML to call.
   - Tests import helpers directly: `import "../contents/js/utils.js" as Utils`.

3) Centralized logging
   - Use `Utils.debugLog(level, ...args)` instead of sprinkling `console.log` across QML.
   - Policy: `debug`/`info` are gated by `Plasmoid.configuration.debugLogs` (or test config via `Utils.debugLogSetTestConfig`); `warn`/`error` always emit.
   - For tests, rely on `Utils.debugLog._lastCall` or `debugLogSetTestConfig` to validate behavior.

4) Networking & XHR pattern
   - Use `XMLHttpRequest` with an abort timer and a stored reference to the current XHR (`root._currentXhr`) so requests can be canceled on timeout.
   - Separate URL normalization into `Utils.buildServerUrl(base, endpoint)`.
   - If streaming responses, track how much of the response has been processed (e.g., `lastProcessedLength`) and only process new data.

5) Connection & readiness state
   - Centralize server health checking in `ConnectionManager.qml`. Expose `status`, `connected` and `error` properties.
   - Other components should *read* these properties to decide UI visibility (e.g., `hasLocalModel`) and behavior.

6) UI component patterns & binding rules
   - Always put `import` statements at the top of QML files.
   - Prefer `property alias` for wiring child control state to top-level properties (KCM `cfg_*` aliases are an example).
   - Keep change handlers side-effect-free when possible; mutate top-level state instead so it is testable.
   - Use `hoverArea.containsMouse` for reliable tooltip visibility.

7) Model & state management
   - Keep a visual `ListModel` for UI rendering and a separate `promptArray` for the conversation payload sent to the server.
   - Provide explicit functions for deleting entries that update both structures.

8) Testing conventions
   - Test files: `tests/tst_*.qml` using Qt Quick Test.
   - Use `scripts/run-tests.sh` or `./build.sh test` to run the suite with the correct imports for Qt6.
   - Avoid writing to protected globals (e.g., `plasmoid`) in tests; use test hooks or helper setters like `Utils.debugLogSetTestConfig`.

9) Naming conventions & small idioms
   - KCM properties: `cfg_<name>` and optional `cfg_<name>Default`.
   - Use `Utils.*` for JS helpers and verb-first names for functions (`buildServerUrl`, `parseTextToComboBox`).
   - QML ids: use descriptive short ids (`connMgr`, `messageField`, `listModel`).

10) Error handling & user feedback
    - Surface network errors via `ConnectionManager.error` and show non-blocking UI feedback.
    - Use `Utils.debugLog('error', ...)` for server/network errors, and prefer descriptive messages.

11) Performance & UX practices
    - Stream responses incrementally and avoid reparsing the entire response repeatedly.
    - Reduce UI thrash by batching model/list updates and limiting costly reflows.
    - Use adaptive polling intervals for connection checks (connected vs disconnected intervals).

