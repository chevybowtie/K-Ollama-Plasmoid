# ChatQT
ChatQT is an enhanced Ollama client for KDE Plasma where you can quickly chat with all your local models downloaded with Ollama. Features a modern interface with persistent settings, configurable input behavior, and robust error handling.



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

Before installing ChatQT, ensure you have the following:

- **KDE Plasma 6** or later
- **Ollama** installed and running (locally: , or on your own server) - download from [ollama.ai](https://ollama.ai)
- **Git** for cloning the repository
- **kpackagetool6** (usually included with KDE Plasma development packages)


## Installation from Source

### Method 1: Using kpackagetool6 (Recommended)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/chevybowtie/ChatQT-Plasmoid-remote.git
   cd ChatQT-Plasmoid-remote
   ```

2. **Install the plasmoid:**
   ```bash
   kpackagetool6 -i .
   ```

3. **Add the widget to your panel:**
   - Right-click on your KDE panel
   - Select "Add Widgets..."
   - Search for "ChatQT"
   - Drag it to your panel or desktop

### Method 2: Manual Installation

1. **Clone and copy to the plasmoids directory:**
   ```bash
   git clone https://github.com/chevybowtie/ChatQT-Plasmoid-remote.git
   cd ChatQT-Plasmoid-remote
   
   # Copy to user plasmoids directory
   mkdir -p ~/.local/share/plasma/plasmoids/ChatQT-Plasmoid
   cp -r * ~/.local/share/plasma/plasmoids/ChatQT-Plasmoid/
   ```

2. **Restart Plasma (optional but recommended):**
   ```bash
   plasmashell --replace &
   ```

3. **Add the widget as described in Method 1, step 3**

## Configuration

After installation, right-click the ChatQT widget and select "Configure..." to access these options:

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

1. **Click the ChatQT widget** in your panel to open the chat interface

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
- Check if the installation was successful: `kpackagetool6 -l | grep ChatQT`

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

### Pin button not working
- Ensure you're using the latest version with the pin functionality fixes
- Try toggling the pin state a few times to refresh the behavior

### Performance issues during AI responses
- The latest version includes optimized streaming to prevent UI blocking
- If issues persist, check your network connection to the Ollama server

## Development

### Testing the plasmoid during development

1. **Use plasmoidviewer for testing:**
   ```bash
   plasmoidviewer -a .
   ```

2. **For live development with auto-reload:**
   ```bash
   # Install in development mode
   kpackagetool6 -i . --dev
   
   # Make changes and reload
   kpackagetool6 -u .
   ```

### Uninstalling

To remove the plasmoid:

```bash
kpackagetool6 -r ChatQT-Plasmoid
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `plasmoidviewer -a .`
5. Submit a pull request

## License

This project is licensed under the LGPL-2.1+ License. See the [LICENSE](LICENSE) file for details.
