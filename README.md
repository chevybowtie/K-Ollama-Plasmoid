# ChatQT
ChatQT is an Ollama client where you can quickly chat with all your local models downloaded with Ollama.

![Screenshot_20240801_204909](https://github.com/user-attachments/assets/ad1d04b2-480e-46d4-b27e-25fc8fca594b)

![ChatQT](https://github.com/user-attachments/assets/5c1d6b57-da20-4f1e-b325-ef52363f2366)

## Prerequisites

Before installing ChatQT, ensure you have the following:

- **KDE Plasma 6** or later
- **Ollama** installed and running (download from [ollama.ai](https://ollama.ai))
- **Git** for cloning the repository
- **kpackagetool6** (usually included with KDE Plasma development packages)

### Installing Ollama

If you don't have Ollama installed:

```bash
# Linux/macOS
curl -fsSL https://ollama.ai/install.sh | sh

# Or download from https://ollama.ai/download
```

After installation, start Ollama and download a model:

```bash
# Start Ollama service
ollama serve

# In another terminal, download a model (e.g., llama2)
ollama pull llama2
```

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

After installation:

1. **Right-click the ChatQT widget** and select "Configure..."

2. **Appearance Tab:**
   - Choose between filled or outlined icons
   - Select light or dark variants
   - Pick adaptive icons that change based on your theme

3. **Server Tab:**
   - Set your Ollama server URL (default: `http://127.0.0.1:11434`)
   - For remote servers, use the appropriate IP address (e.g., `http://192.168.1.100:11434`)

## Usage

1. **Ensure Ollama is running:**
   ```bash
   ollama serve
   ```

2. **Verify you have models downloaded:**
   ```bash
   ollama list
   ```

3. **Click the ChatQT widget** in your panel to open the chat interface

4. **Select a model** from the dropdown menu

5. **Start chatting** with your local AI models!

## Troubleshooting

### Widget doesn't appear in the add widgets menu
- Try restarting Plasma: `plasmashell --replace &`
- Check if the installation was successful: `kpackagetool6 -l | grep ChatQT`

### Can't connect to Ollama
- Ensure Ollama is running: `ollama serve`
- Check if Ollama is accessible: `curl http://127.0.0.1:11434/api/tags`
- Verify the server URL in widget configuration

### No models available
- Download models: `ollama pull llama2` (or your preferred model)
- Restart the widget after downloading new models

### Widget shows "No local model found"
- Make sure Ollama is running and accessible
- Check your server URL configuration
- Verify models are installed: `ollama list`

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
