# K-Ollama Plasmoid

A modern KDE Plasma widget for chatting with your local or remote Ollama AI models. Features a clean interface, persistent settings, configurable input behavior, and robust error handling.

> Based on Denys Madureira's original code, modernized for KDE Plasma 6. See [CONTRIBUTORS.md](./CONTRIBUTORS.md) for details.

## Features

- **Multi-Model Support** - Switch between all your Ollama models
- **Persistent Settings** - Remembers your configuration across sessions  
- **Configurable Input** - Enter-to-send or Ctrl+Enter-to-send modes
- **Markdown Rendering** - Optional markdown formatting in AI responses (disabled by default)
- **Pin Widget** - Keep chat open while working
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

1. **Clone the repository:**
   ```bash
   git clone https://github.com/chevybowtie/K-Ollama-Plasmoid.git
   cd K-Ollama-Plasmoid
   ```

2. **Install using kpackagetool6:**
   ```bash
   kpackagetool6 -i .
   ```

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
   # Create the plasmoid directory if it doesn't exist
   mkdir -p ~/.local/share/plasma/plasmoids/K-Ollama-Plasmoid
   
   # Copy source and restart Plasma (this is the reliable method)
   cp -rf * ~/.local/share/plasma/plasmoids/K-Ollama-Plasmoid/ && plasmashell --replace &
   ```

3. **Add widget to test:**
   - Right-click panel → "Add Widgets..." → Search "K-Ollama" → Add

### Development Workflow

**Making changes:**
```bash
# Edit your code, then apply changes:
cp -rf * ~/.local/share/plasma/plasmoids/K-Ollama-Plasmoid/ && plasmashell --replace &
```

**Running tests:**
```bash
./scripts/run-tests
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
- **Text Rendering**: Enable markdown formatting in AI responses:
  - **Disabled** (default): Responses shown as plain text
  - **Enabled**: Supports bold, italics, code blocks, lists, headers, and other markdown formatting

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

5. **Enable markdown rendering** (optional) in Appearance & Behavior settings to see formatted AI responses with bold text, code blocks, lists, etc.

6. **Start chatting** with your AI models! The input field is automatically focused and ready for typing

7. **Copy responses** using the copy button that appears when hovering over messages

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


## Testing

The project includes comprehensive QML unit tests (98 tests covering UI, utilities, error handling, and performance).

### Running Tests

**Quick test run:**
```bash
./scripts/run-tests
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
./scripts/run-tests -v2

# Skip QML linting (faster iteration)
SKIP_QML_LINT=1 ./scripts/run-tests

# Use specific qmltestrunner
QMLTEST_RUNNER=/opt/qt6/bin/qmltestrunner ./scripts/run-tests
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
   ./scripts/run-tests
   ```

6. **Submit a pull request** with a clear description of your changes

### Development Notes
- Tests must pass: `./scripts/run-tests`
- Follow existing code style and patterns

### Roadmap
- [x] Stop generating button & connection status
- [x] Temperature settings & message management  
- [x] Debug logging & comprehensive UI tests
- [x] Centralized request cleanup with finishRequest() helper
- [ ] Esc-to-abort in flight conversation
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

## Contributors

See [CONTRIBUTORS.md](./CONTRIBUTORS.md) for a list of contributors and their contributions.

## License

This project is licensed under the LGPL-2.1+ License. See the [LICENSE](LICENSE) file for details.

**Original Author:** Denys Madureira  
**Enhanced by:** Paul Sturm (2025) - See CONTRIBUTORS.md for detailed contributions
