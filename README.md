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

#### Install / Upgrade notes

- If you get an error like:

  Error: Installation of /path/to/repo failed: .../.local/share/kpackage/generic/K-Ollama-Plasmoid already exists

  It means the package is already installed on your system. You have three safe options:

  1. Upgrade the installed package in-place (recommended for development):

     ```bash
     # update the installed package from the current working tree
     kpackagetool6 -u .
     ```

     This replaces files in the installed package with the files from the current directory and is non-destructive.

  2. Remove then reinstall (clean install):

     ```bash
     # remove the installed package by name (use the pluginId from metadata.json)
     kpackagetool6 -r K-Ollama-Plasmoid
     kpackagetool6 -i .
     ```

  3. Manually remove the installed folder and install (last resort):

     ```bash
     rm -rf ~/.local/share/kpackage/generic/K-Ollama-Plasmoid
     kpackagetool6 -i .
     ```

- After installing or upgrading, reload Plasma so the running shell sees the new files:

  ```bash
  # graceful reload
  kquitapp5 plasmashell && kstart5 plasmashell

  # or in a terminal session (may briefly flicker the UI)
  plasmashell --replace &
  ```

- For quick development testing without switching your entire session, use `plasmoidviewer`:

  ```bash
  plasmoidviewer -a .
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

### Development Workflow

**Making changes:**
```bash
# Edit your code, then apply changes:
cp -rf * ~/.local/share/plasma/plasmoids/K-Ollama-Plasmoid/ && plasmashell --replace &
```

**Running tests:**
```bash
./scripts/run-tests.sh
```

### Troubleshooting Development

**If you get installation errors with kpackagetool6:**
```bash
# Remove existing installation and reinstall
kpackagetool6 -r K-Ollama-Plasmoid
kpackagetool6 -i .
```





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
- Check if the installation was successful: `kpackagetool6 -t Plasma/Applet -l  | grep K-Ollama`

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
./scripts/run-tests.sh
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
# Run with verbose output
./scripts/run-tests.sh -v2

# Skip QML linting (faster iteration)
SKIP_QML_LINT=1 ./scripts/run-tests.sh

# Use specific qmltestrunner
QMLTEST_RUNNER=/opt/qt6/bin/qmltestrunner ./scripts/run-tests.sh
```

- Run a single test file:

```bash
/usr/lib/qt6/bin/qmltestrunner -import /usr/lib/x86_64-linux-gnu/qt6/qml tests/tst_utils.qml
```

If `qmltestrunner` on your PATH is pointing to Qt5 (qtchooser), run the Qt6 binary directly as shown above. There is also a small convenience wrapper included in this repo to avoid remembering the -import flags:

Using the provided wrapper

This repository includes `scripts/run-tests`, a small wrapper that detects `qmltestrunner` (or you can set `QMLTEST_RUNNER`) and runs the tests with the correct `-import` and `-input` flags so the tests can import the runtime JS helpers.

Before invoking the tests, the wrapper validates every QML file under `contents/` with `qmllint`. By default it tries to use the Qt6 tooling (`/usr/lib/qt6/bin/qmllint`) and falls back to whatever is found on `PATH`. Some common environment knobs:

- `QMLLINT_BIN` – override the `qmllint` binary.
- `SKIP_QML_LINT=1` – skip the validation step entirely (useful while iterating without KDE imports available).
- `QML_LINT_EXTRA_QMLDIRS=/path/one:/path/two` – add extra search paths so `qmllint` can resolve custom modules.
- `QML_LINT_EXTRA_ARGS="--foo info --bar warning"` – pass additional raw arguments to `qmllint`.
- `QML_LINT_DISABLE_DEFAULT_FILTERS=1` – restore the original warning levels if you want `--import`/`--missing-type`/`--unresolved-type` to fail the run.

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

2. **For quick local development/deploy:**
   The simplest, reliable way to test changes locally is to copy the workspace into your user plasmoids folder and restart Plasma:

   ```bash
   # Copy current tree to the user plasmoids directory and restart Plasma
   cp -rf * ~/.local/share/plasma/plasmoids/K-Ollama-Plasmoid/ && plasmashell --replace &
   ```

### TODO
- [x] `stop generating` button
- [x] connection status icon
- [ ] allow a system prompt
- [x] temperature setting
- [x] up-arrow populates last user message so it may be edited
- [x] delete message from conversation
- [x] add UI setting to turn on debugging logs (console.log type statements)
- [ ] add a request timeout
- [ ] add retry/backoff for transient failures
- [ ] UI tests
- [ ] add a single cleanup helper finishRequest(reason) that clears root.currentXhr, sets isLoading=false, and logs the reason. Use it in onload, onerror, onabort.
- [ ] Esc-to-abort keyboard shortcut for stop
- [ ] allow configuration as a desktop widget instead of only a panel widget



## Contributing

### Quick Contribution Guide

1. **Fork the repository** on GitHub
2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/K-Ollama-Plasmoid.git
   cd K-Ollama-Plasmoid
   ```

3. **Set up development environment:**
   ```bash
   # Install for local testing
   cp -rf * ~/.local/share/plasma/plasmoids/K-Ollama-Plasmoid/ && plasmashell --replace &
   ```

4. **Create a feature branch:**
   ```bash
   git checkout -b fix-something-awesome
   ```

5. **Make your changes and test:**
   ```bash
   # Apply changes during development
   cp -rf * ~/.local/share/plasma/plasmoids/K-Ollama-Plasmoid/ && plasmashell --replace &
   
   # Run tests
   ./scripts/run-tests.sh
   ```

6. **Submit a pull request** with a clear description of your changes

### Development Notes
- Tests must pass: `./scripts/run-tests.sh`
- Follow existing code style and patterns

### Roadmap
- [x] Stop generating button & connection status
- [x] Temperature settings & message management  
- [x] Debug logging & comprehensive UI tests
- [x] Centralized request cleanup with finishRequest() helper
- [x] Esc-to-abort in flight conversation
- [ ] allow a system prompt
    {
      "role": "system",
      "content": "You are a helpful assistant that answers questions in plain English."
    }
- [ ] add a request timeout
- [ ] add retry/backoff for transient failures
- [x] UI tests
- [x] add support for rendering markdown
- [x] add option to disable scroll in desktop mode
- [ ] explore mic input

## Contributors

See [CONTRIBUTORS.md](./CONTRIBUTORS.md) for a list of contributors and their contributions.

## License

This project is licensed under the LGPL-2.1+ License. See the [LICENSE](LICENSE) file for details.

**Original Author:** Denys Madureira  
**Enhanced by:** Paul Sturm (2025) - See CONTRIBUTORS.md for detailed contributions
