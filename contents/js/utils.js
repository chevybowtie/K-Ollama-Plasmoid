// Utility helpers for K-Ollama plasmoid

/**
 * Determine whether the caret (cursor) is on the first line of the given text.
 *
 * @param {string} text - The full text content of the input.
 * @param {number} cursorPosition - The caret index (0-based) within `text`.
 * @returns {boolean} True if the caret is on the first line (no newline before cursor) or text is empty.
 */
function caretIsOnFirstLine(text, cursorPosition) {
    if (!text || cursorPosition <= 0) return true;
    var textBefore = text.substring(0, cursorPosition);
    return textBefore.indexOf('\n') === -1;
}


/**
 * Build a server API URL from a base and an endpoint, normalizing slashes.
 *
 * If `baseUrl` is falsy, the default base `http://127.0.0.1:11434` is used.
 * Leading slashes on `endpoint` and trailing slashes on `baseUrl` are removed to
 * avoid accidental double slashes when concatenating. The returned string will
 * always include the `/api/` path segment.
 *
 * @param {string|undefined|null} baseUrl - Base server URL (e.g., 'http://127.0.0.1:11434').
 * @param {string|undefined|null} endpoint - Endpoint path (e.g., 'tags' or '/tags').
 * @returns {string} The full API URL.
 */
function getServerUrl(baseUrl, endpoint) {
    var base = baseUrl || 'http://127.0.0.1:11434';
    // Trim trailing slash from base and leading slash from endpoint to avoid double slashes
    base = base.replace(/\/+$/, '');
    endpoint = (endpoint || '').replace(/^\/+/, '');
    return base + '/api/' + endpoint;
}


/**
 * Convert a model identifier string into a human-friendly label used in the
 * combo box (e.g., 'gpt-4o:latest' -> 'Gpt 4o (Latest)').
 *
 * Behavior:
 * - Hyphens are turned into spaces.
 * - A trailing ":tag" or ":(tag)" is converted into " (Tag)".
 * - Each word is capitalized. If a word starts with '(', the first character
 *   after '(' is capitalized instead (to produce '(Alpha)').
 *
 * @param {string} text - The raw model identifier string.
 * @returns {string} Human-friendly label.
 */
function parseTextToComboBox(text) {
    if (!text) return "";
    var s = text.replace(/-/g, ' ');
    // Convert ":latest" or ":(alpha)" into " (Latest)" or " (Alpha)" without duplicating parentheses
    s = s.replace(/:\(?(.+?)\)?$/, function(_, m) { return ' (' + m + ')'; });
    return s.split(' ').map(function(word) {
        if (!word) return word;
        if (word.charAt(0) === '(') {
            // Capitalize the first letter after the opening parenthesis
            if (word.length >= 2) {
                return '(' + word.charAt(1).toUpperCase() + word.slice(2);
            }
            return word;
        }
        return word.charAt(0).toUpperCase() + word.slice(1);
    }).join(' ');
}

/**
 * Determine contrast label ('dark'|'light') from a hex color string like '#rrggbb'.
 * @param {string} hexColor - color string beginning with '#' followed by 6 hex digits.
 * @returns {string} 'dark' if luma > 128 else 'light'
 */
function getBackgroundColorContrastFromHex(hexColor) {
    if (!hexColor || hexColor.length < 7) return 'light';
    var hex = ('' + hexColor).substring(1);
    var r = parseInt(hex.substring(0, 2), 16);
    var g = parseInt(hex.substring(2, 4), 16);
    var b = parseInt(hex.substring(4, 6), 16);
    var luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    return luma > 128 ? 'dark' : 'light';
}

/**
 * Choose icon filename based on configuration and colorContrast.
 * @param {object} config - an object with boolean flags matching Plasmoid.configuration
 * @param {string} colorContrast - 'dark'|'light'
 * @returns {string} relative path to the chosen SVG asset
 */
function chooseIconPath(config, colorContrast) {
    if (config.useFilledDarkIcon) return 'assets/logo-filled-dark.svg';
    if (config.useFilledLightIcon) return 'assets/logo-filled-light.svg';
    if (config.useOutlinedDarkIcon) return 'assets/logo-outlined-dark.svg';
    if (config.useOutlinedLightIcon) return 'assets/logo-outlined-light.svg';
    if (config.useOutlinedIcon) return `assets/logo-outlined-${colorContrast}.svg`;
    return `assets/logo-filled-${colorContrast}.svg`;
}

/**
 * Normalize a server base URL (trim trailing slashes) and build a final URL by joining endpoint.
 * @param {string|null|undefined} baseUrl
 * @param {string} endpoint (may include leading slash)
 * @returns {string}
 */
function buildServerUrl(baseUrl, endpoint) {
    var base = baseUrl || 'http://127.0.0.1:11434';
    base = ('' + base).replace(/\/+$/, '');
    endpoint = (endpoint || '').replace(/^\/+/, '');
    return base + (endpoint ? '/' + endpoint : '');
}


/**
 * Centralized debug logging helper.
 *
 * Levels supported: 'debug', 'info', 'warn', 'error'.
 * - 'debug' and 'info' messages are emitted only when plasmoid.configuration.debugLogs is truthy.
 * - 'warn' and 'error' are always emitted.
 *
 * Usage from QML: Utils.debugLog('debug', 'Some message', var1, var2)
 */
function debugLog(level) {
    try {
        var args = Array.prototype.slice.call(arguments, 1);
        var lvl = (level || 'debug').toString().toLowerCase();

        // Determine whether to emit
        var emit = true;
        if (lvl === 'debug' || lvl === 'info') {
            // Allow tests to inject a stubbed plasmoid configuration via debugLog._testConfig
            if (typeof debugLog._testConfig !== 'undefined' && debugLog._testConfig && debugLog._testConfig.configuration) {
                emit = !!debugLog._testConfig.configuration.debugLogs;
            } else {
                emit = (typeof plasmoid !== 'undefined' && plasmoid.configuration && plasmoid.configuration.debugLogs);
            }
        }

        if (!emit) return;

        // For tests: record the last emitted call (level and args)
        try { debugLog._lastCall = { level: lvl, args: args }; } catch(e) {}

        if (lvl === 'warn') {
            console.warn.apply(console, args);
        } else if (lvl === 'error') {
            console.error.apply(console, args);
        } else {
            // debug/info -> console.log
            console.log.apply(console, args);
        }
    } catch (e) {
        // If something goes wrong in the logger, don't throw.
    }
}

/**
 * Test helper: set a test configuration object used by debugLog for unit tests.
 * Example: Utils.debugLogSetTestConfig({ configuration: { debugLogs: true } })
 */
function debugLogSetTestConfig(obj) {
    try { debugLog._testConfig = obj; } catch (e) {}
}
