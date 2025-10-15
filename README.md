# K-Ollama Plasmoid

A modern KDE Plasma widget for chatting with your local or remote Ollama AI models. Features a clean interface, persistent settings, configurable input behavior, and robust error handling.

> Based on Denys Madureira's original code, modernized for KDE Plasma 6. See [CONTRIBUTORS.md](./CONTRIBUTORS.md) for details.

## Features

- **Multi-Model Support** - Switch between all your Ollama models
- **Persistent Settings** - Remembers your configuration across sessions  
- **Configurable Input** - Enter-to-send or Ctrl+Enter-to-send modes
- **Markdown Rendering** - Optional markdown formatting in AI responses (disabled by default)
- **Pin Widget** - Keep chat open while working (panel mode only)
- **Multiple Themes** - Adaptive, filled, outlined icons (light/dark)
- **Remote Servers** - Connect to Ollama on other machines
- **Copy Messages** - One-click copying of AI responses
- **Optimized Streaming** - Real-time responses without UI blocking

## Quick Start

### Prerequisites
- **KDE Plasma 6** 
- **Ollama** running locally or remotely ([ollama.ai](https://ollama.ai))
- **Git** for cloning


### Installation (End Users)

#### Option 1: KDE Store (Recommended)
Once published, install directly from KDE:
1. **Right-click on your KDE panel** → "Add Widgets..."
2. **Click "Get New Widgets"** → "Download New Plasma Widgets"
3. **Search for "K-Ollama"** → Click "Install"

#### Option 2: Download .plasmoid Package
1. **Download the latest release** from [GitHub Releases](https://github.com/chevybowtie/K-Ollama-Plasmoid/releases)
   - Each release automatically includes a `.plasmoid` package file
   - No need to build or compile anything
2. **Install the package:**
   ```bash
   kpackagetool6 --type Plasma/Applet --install K-Ollama-1.0.0.plasmoid
   ```
3. **Add to your panel:**
   - Right-click on your KDE panel → "Add Widgets..."
   - Search for "K-Ollama" → Drag to panel

#### Option 3: Development Installation
For testing or development:
1. **Clone the repository:**
   ```bash
   git clone https://github.com/chevybowtie/K-Ollama-Plasmoid.git
   cd K-Ollama-Plasmoid
   ```

2. **Install using the development script:**
   ```bash
   ./install.sh dev
   ```

   This automatically removes any existing installation and installs the updated version.

3. **Add to your panel:**
   - Right-click on your KDE panel → "Add Widgets..."
   - Search for "K-Ollama" → Drag to panel

## Development Setup

### For Contributors & Bug Fixes

> **Reliable Development Workflow**  
> The method I use for local development is the copy-and-restart approach below.

1. **Clone and setup:**
   ```bash
   git clone https://github.com/chevybowtie/K-Ollama-Plasmoid.git
   cd K-Ollama-Plasmoid
   ```

2. **Install for development:**
   ```bash
   ./install.sh dev
   ```

### Development Workflow

**Making changes:**
```bash
# Edit your code, then apply changes:
./install.sh dev
```

**Running tests:**
```bash
./scripts/run-tests.sh
```

**Managing translations:**
```bash
./scripts/translate.sh all    # Extract, update, and compile translations
./scripts/translate.sh stats  # Check translation completion
```





## Configuration

After installation, right-click the K-Ollama widget and select "Configure..." to access these options:

### Appearance & Behavior Tab
- **Icon Themes**: Choose between filled or outlined icons with light/dark/adaptive variants
- **Input Behavior**: Configure how Enter key works:
  - **Modern Mode**: Enter sends message, Ctrl+Enter adds new line 
  - **Classic Mode**: Enter adds new line, Ctrl+Enter sends message (default)
- **Text Rendering**: Enable markdown formatting in AI responses:
  - **Disabled** (default): Responses shown as plain text
  - **Enabled**: Supports bold, italics, code blocks, lists, headers, and other markdown formatting

### Server Tab
- **Ollama Server URL**: Set your server location (default: `http://127.0.0.1:11434`)
- **Remote Server Support**: Connect to Ollama on other machines (e.g., `http://192.168.1.100:11434`)
 - **System Prompt** (optional): An optional system message that will be prepended to every request sent to the model. Default:

    > You are a helpful assistant that answers questions in plain English.

    Enable it in the Server tab using "Enable system prompt" and edit the prompt text. Do not include secrets or other sensitive data. Max length: 2048 characters.

### Automatic Settings
- **Model Persistence**: Your selected model is automatically remembered
- **Pin State**: Widget remembers if you prefer it pinned open (panel mode only)

## Usage

1. **Click the K-Ollama widget** in your panel to open the chat interface

2. **Select a model** from the dropdown menu (your choice will be remembered for next time)

3. **Configure input behavior** (optional):
   - Default: Enter adds new line, Ctrl+Enter sends message  
   - Modern: Enter sends message, Ctrl+Enter adds new line

4. **Pin the widget** (optional, panel mode only) using the pin button to keep it open while working

5. **Enable markdown rendering** (optional) in Appearance & Behavior settings to see formatted AI responses with bold text, code blocks, lists, etc.

6. **Start chatting** with your AI models! The input field is automatically focused and ready for typing

7. **Copy responses** using the copy button that appears when hovering over messages

## Troubleshooting

### Widget doesn't appear in the add widgets menu
- Try restarting Plasma: `plasmashell --replace &`
- Check if the installation was successful: `./install.sh status`
- Reinstall if needed: `./install.sh uninstall && ./install.sh dev`

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


## Testing

The project includes comprehensive QML unit tests (98 tests covering UI, utilities, error handling, and performance).

### Running Tests

**Quick test run:**
```bash
./scripts/run-tests.sh
```

**Install test dependencies (Debian/Ubuntu):**
```bash
# For Qt6
sudo apt install qml6-module-qttest libqt6quicktest6

# For Qt5 (if needed)
sudo apt install qml-module-qttest libqt5quicktest5
```

**Test options:**
```bash
# Run with verbose output
./scripts/run-tests.sh -v2

# Skip QML linting (faster iteration)
SKIP_QML_LINT=1 ./scripts/run-tests.sh

# Use specific qmltestrunner
QMLTEST_RUNNER=/opt/qt6/bin/qmltestrunner ./scripts/run-tests.sh
```

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
   ./install.sh dev
   ```

4. **Create a feature branch:**
   ```bash
   git checkout -b fix-something-awesome
   ```

5. **Make your changes and test:**
   ```bash
   # Apply changes during development
   ./install.sh dev
   
   # Run tests
   ./scripts/run-tests.sh
   ```

6. **Update translations if needed:**
   ```bash
   ./scripts/translate.sh all
   ```
