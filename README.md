# K-Ollama
K-Ollama is an enhanced Ollama client for KDE Plasma where you can quickly chat with all your local models downloaded with Ollama. Features a modern interface with persistent settings, configurable input behavior, and robust error handling. This is based on `Denys Madureira` original code but modernized for KDE 6 (see [CONTRIBUTORS.md](./CONTRIBUTORS.md))



## Features

- **Multi-Model Support**: Seamlessly switch between all your Ollama models
- **Persistent Settings**: Remembers your preferred model and configuration across sessions
- **Configurable Input**: Choose between Enter-to-send or Ctrl+Enter-to-send behaviors
- **Pin Widget**: Keep the chat interface open while working
- **Multiple Icon Themes**: Adaptive, filled, outlined icons in light/dark variants
- **Remote Server Support**: Connect to Ollama running on remote servers
- **Copy Messages**: Easy one-click copying of AI responses
- **Auto-Focus**: Input field automatically focused when widget opens
- **Optimized Streaming**: Smooth real-time response streaming without UI blocking

## Prerequisites

Before installing K-Ollama, ensure you have the following:

- **KDE Plasma 6** or later
- **Ollama** installed and running (locally or on your own server) - download from [ollama.ai](https://ollama.ai)
- **Git** for cloning the repository
- **kpackagetool6** (optional) usually included with KDE Plasma development packages


## Installation from Source

### Method 1: Using kpackagetool6 (Recommended)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/chevybowtie/K-Ollama-Plasmoid.git
   cd K-Ollama-Plasmoid
   ```

2. **Install the plasmoid:**
   ```bash
   kpackagetool6 -i .
   ```

3. **Add the widget to your panel:**
   - Right-click on your KDE panel
   - Select "Add Widgets..."
   - Search for "K-Ollama"
   - Drag it to your panel or desktop






### Method 2: Manual Installation

1. **Clone and copy to the plasmoids directory:**
   ```bash
   git clone https://github.com/chevybowtie/K-Ollama-Plasmoid.git
   cd K-Ollama-Plasmoid
   
   # Copy to user plasmoids directory
   mkdir -p ~/.local/share/plasma/plasmoids/K-Ollama-Plasmoid
   cp -r * ~/.local/share/plasma/plasmoids/K-Ollama-Plasmoid/
   ```

2. **Restart Plasma (optional but recommended):**
   ```bash
   plasmashell --replace &
   ```

3. **Add the widget as described in Method 1, step 3**





## Configuration

After installation, right-click the K-Ollama widget and select "Configure..." to access these options:

### Appearance & Behavior Tab
- **Icon Themes**: Choose between filled or outlined icons with light/dark/adaptive variants
- **Input Behavior**: Configure how Enter key works:
  - **Modern Mode**: Enter sends message, Ctrl+Enter adds new line 
  - **Classic Mode**: Enter adds new line, Ctrl+Enter sends message (default)

### Server Tab
- **Ollama Server URL**: Set your server location (default: `http://127.0.0.1:11434`)
- **Remote Server Support**: Connect to Ollama on other machines (e.g., `http://192.168.1.100:11434`)

### Automatic Settings
- **Model Persistence**: Your selected model is automatically remembered
- **Pin State**: Widget remembers if you prefer it pinned open

## Usage

1. **Click the K-Ollama widget** in your panel to open the chat interface

2. **Select a model** from the dropdown menu (your choice will be remembered for next time)

3. **Configure input behavior** (optional):
   - Default: Enter adds new line, Ctrl+Enter sends message  
   - Modern: Enter sends message, Ctrl+Enter adds new line

4. **Pin the widget** (optional) using the pin button to keep it open while working

5. **Start chatting** with your AI models! The input field is automatically focused and ready for typing

6. **Copy responses** using the copy button that appears when hovering over messages

## Troubleshooting

### Widget doesn't appear in the add widgets menu
- Try restarting Plasma: `plasmashell --replace &`
- Check if the installation was successful: `kpackagetool6 -l | grep K-Ollama`

### Can't connect to Ollama
- Ensure Ollama is running: `ollama serve`
- Check if Ollama is accessible: 
  - locally: `curl http://127.0.0.1:11434/api/tags` 
  - remotely: `curl http://{your-servers-ip}:11434/api/tags` 
- Verify the server URL in widget configuration

### No models available
- Make sure Ollama is running and accessible
- Check your server URL configuration  
- Verify models are installed: `ollama list`
- Restart the widget after downloading new models

### Input behavior not working as expected
- Check your configuration in "Appearance & Behavior" → "Input behavior"
- Remember: Default mode uses Ctrl+Enter to send, Modern mode uses Enter to send


## Development

### Testing the plasmoid during development
Running tests (Qt Quick Test)

If you want to run the QML unit tests locally we use Qt Quick Test (QtTest). On Debian 13 (trixie) you can install the Qt6 test modules with:

```bash
sudo apt update
sudo apt install -y qml6-module-qttest libqt6quicktest6
```

Notes:
- The package `qml6-module-qttest` provides the QML import `import QtTest 1.x` for Qt6.
- If your system defaults to Qt5 you can install the Qt5 equivalents instead:

```bash
sudo apt install -y qml-module-qttest libqt5quicktest5
```

Running the tests
- Run all tests in the `tests/` directory (Qt6):

```bash
/usr/lib/qt6/bin/qmltestrunner -import /usr/lib/x86_64-linux-gnu/qt6/qml -input tests
```

- Run a single test file:

```bash
/usr/lib/qt6/bin/qmltestrunner -import /usr/lib/x86_64-linux-gnu/qt6/qml tests/tst_utils.qml
```

If `qmltestrunner` on your PATH is pointing to Qt5 (qtchooser), run the Qt6 binary directly as shown above. There is also a small convenience wrapper included in this repo to avoid remembering the -import flags:

Using the provided wrapper

This repository includes `scripts/run-tests`, a small wrapper that detects `qmltestrunner` (or you can set `QMLTEST_RUNNER`) and runs the tests with the correct `-import` and `-input` flags so the tests can import the runtime JS helpers.

Examples:

```bash
# Run all tests using the detected runner
scripts/run-tests

# Force a specific qmltestrunner (e.g. custom Qt6 install)
QMLTEST_RUNNER=/opt/qt/6.8.2/bin/qmltestrunner scripts/run-tests

# Pass additional qmltestrunner args (verbose, output file, etc.)
scripts/run-tests -v2 -o tests/results.txt,txt
```

Development and live reload
1. **Use plasmoidviewer for manual testing:**
   ```bash
   plasmoidviewer -a .
   ```

   Tests reuse runtime JS helpers
    - The QML tests import the shared JavaScript helpers directly from the source tree, so test logic is single-sourced with the plasmoid runtime.
    - Example (inside a test QML file):
       import "../contents/js/utils.js" as Utils
       // call: Utils.caretIsOnFirstLine(text, cursorPosition)

2. **For live development with auto-reload:**
   ```bash
   # Install in development mode
   kpackagetool6 -i . --dev

   # Make changes and reload
   kpackagetool6 -u .
   ```

### TODO
- [ ] `stop generating` button
- [x] connection status icon
- [ ] single system prompt
- [ ] token limit setting
- [x] temperature setting
- [x] up-arrow populates last user message so it may be edited
- [x] delete message from conversation
- [x] add UI setting to turn on debugging logs (console.log type statements)



## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `plasmoidviewer -a .`
5. Submit a pull request

## Contributors

See [CONTRIBUTORS.md](./CONTRIBUTORS.md) for a list of contributors and their contributions.

## License

This project is licensed under the LGPL-2.1+ License. See the [LICENSE](LICENSE) file for details.

**Original Author:** Denys Madureira  
**Enhanced by:** Paul Sturm (2025) - See CONTRIBUTORS.md for detailed contributions
