// Utility helpers for K-Ollama plasmoid

function caretIsOnFirstLine(text, cursorPosition) {
    if (!text || cursorPosition <= 0) return true;
    var textBefore = text.substring(0, cursorPosition);
    return textBefore.indexOf('\n') === -1;
}
