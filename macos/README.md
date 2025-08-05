# MkDocs Local Development Setup - macOS

This script automates the setup of a local MkDocs development environment on macOS for Amerintlxperts documentation tracks.

## Prerequisites

- macOS 10.15 (Catalina) or later
- Git (usually pre-installed)
- Internet connection for downloading dependencies

## Features

- **Python 3.11 Detection**: Checks for Python 3.11.x and provides installation guidance if not found
- **Developer Tools Check**: Ensures Xcode Command Line Tools are installed for building packages
- **Virtual Environment**: Creates an isolated Python environment for the project
- **Automatic Package Installation**: Installs MkDocs and all required plugins
- **Repository Cloning**: Sets up track-specific playground directories
- **Theme Integration**: Automatically configures themes and assets
- **Local Development Ready**: Prepares everything for `mkdocs serve`

## Usage

1. **Download the script** to your desired directory
2. **Open Terminal** and navigate to the script location
3. **Run the script** with your track name:
   ```bash
   ./setup_local_mkdocs.sh <track>
   ```
   
   For example:
   ```bash
   ./setup_local_mkdocs.sh ot
   ./setup_local_mkdocs.sh sase
   ./setup_local_mkdocs.sh secops
   ```

## What the Script Does

1. **Checks Python 3.11**: Verifies you have Python 3.11.x installed
2. **Checks Developer Tools**: Ensures Xcode Command Line Tools are available
3. **Creates Virtual Environment**: Sets up `venv` in the current directory
4. **Installs Dependencies**: Downloads and installs MkDocs and all plugins
5. **Clones Repositories**: 
   - Creates `<track>-playground` directory
   - Clones theme repository
   - Clones track-specific content into `docs/` directory
6. **Configures Environment**: Sets up mkdocs.yml and theme assets for local development

## After Setup

Once the script completes successfully, you can serve your documentation:

```bash
cd <track>-playground
source ../venv/bin/activate
mkdocs serve
```

Your documentation will be available at `http://127.0.0.1:8000`

## Installing Python 3.11

If you don't have Python 3.11, the script will provide instructions. Here are the recommended methods:

### Option 1: Homebrew (Recommended)
```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python 3.11
brew install python@3.11
```

### Option 2: Official Python Installer
1. Download Python 3.11.5 from: https://www.python.org/downloads/release/python-3115/
2. Run the installer and ensure "Add Python to PATH" is checked

## Troubleshooting

### "command not found: python3"
- Install Python 3.11 using one of the methods above
- Restart your terminal after installation

### "xcode-select: error: invalid developer directory"
- Run: `xcode-select --install`
- Follow the prompts to install Xcode Command Line Tools

### "Permission denied" when running the script
- Make sure the script is executable: `chmod +x setup_local_mkdocs.sh`

### Package installation fails
- Ensure you have the latest Xcode Command Line Tools
- Try running: `xcode-select --reset` then `xcode-select --install`

## Directory Structure After Setup

```
your-working-directory/
├── venv/                          # Python virtual environment
└── <track>-playground/           # Track-specific workspace
    ├── docs/                     # Track content (from GitHub)
    ├── theme/                    # Theme files (from GitHub)
    └── mkdocs.yml               # MkDocs configuration
```

## Cleanup

To remove a track playground:
```bash
rm -rf <track>-playground
```

To remove the virtual environment:
```bash
rm -rf venv
```
