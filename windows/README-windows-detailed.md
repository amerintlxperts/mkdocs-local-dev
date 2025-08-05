# MkDocs Local Development Setup - Windows

This PowerShell script automates the setup of a local MkDocs development environment on Windows for Amerintlxperts documentation tracks.

## Prerequisites

- Windows 10 or later
- PowerShell 5.0 or later
- Git for Windows
- Internet connection for downloading dependencies
- **Run as Administrator** (required for some operations)

## Features

- **Python 3.11 Detection**: Checks for Python 3.11.x and provides installation guidance if not found
- **Build Tools Check**: Ensures Visual C++ Build Tools are available for building packages
- **Virtual Environment**: Creates an isolated Python environment for the project
- **Automatic Package Installation**: Installs MkDocs and all required plugins
- **Repository Cloning**: Sets up track-specific playground directories
- **Theme Integration**: Automatically configures themes and assets
- **Local Development Ready**: Prepares everything for `mkdocs serve`

## Usage

1. **Download the scripts** to your desired directory
2. **Open PowerShell as Administrator**
3. **Navigate to the script location**
4. **Run the script** with your track name:

   ```powershell
   .\setup_local_mkdocs.bat <track>
   ```
   
   For example:
   ```powershell
   .\setup_local_mkdocs.bat ot
   .\setup_local_mkdocs.bat sase
   .\setup_local_mkdocs.bat secops
   ```

## What the Script Does

1. **Checks Python 3.11**: Verifies you have Python 3.11.x installed
2. **Checks Build Tools**: Ensures Visual C++ Build Tools are available
3. **Creates Virtual Environment**: Sets up `venv` in the current directory
4. **Installs Dependencies**: Downloads and installs MkDocs and all plugins
5. **Clones Repositories**: 
   - Creates `<track>-playground` directory
   - Clones theme repository
   - Clones track-specific content into `docs\` directory
6. **Configures Environment**: Sets up mkdocs.yml and theme assets for local development

## After Setup

Once the script completes successfully, you can serve your documentation:

```powershell
cd <track>-playground
..\venv\Scripts\Activate.ps1
mkdocs serve
```

Your documentation will be available at `http://127.0.0.1:8000`

## Installing Python 3.11

If you don't have Python 3.11, the script will provide instructions. Here are the recommended methods:

### Option 1: Official Python Installer (Recommended)

1. Download Python 3.11.5 from: [https://www.python.org/downloads/release/python-3115/](https://www.python.org/downloads/release/python-3115/)
2. Run the installer and ensure "Add Python to PATH" is checked
3. Restart PowerShell after installation

### Option 2: Microsoft Store

1. Search for "Python 3.11" in the Microsoft Store
2. Install Python 3.11 (NOT 3.14 or beta versions)

## Troubleshooting

### "Python is not recognized as an internal or external command"

- Install Python 3.11 using one of the methods above
- Ensure "Add Python to PATH" was checked during installation
- Restart PowerShell after installation

### "execution of scripts is disabled on this system"

- Run PowerShell as Administrator
- Execute: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Confirm with 'Y' when prompted

### Package installation fails with compiler errors

- Install Visual Studio Build Tools (the script should handle this automatically)
- Alternatively, install Visual Studio Community with C++ development tools

### Beta Python version detected (3.14b, etc.)

The script will detect beta versions and provide uninstallation instructions:

1. Go to Settings > Apps > Apps & features
2. Search for 'Python' and uninstall any beta versions
3. Install Python 3.11 using the methods above
4. Restart PowerShell and re-run the script

## Directory Structure After Setup

```
your-working-directory\
├── venv\                          # Python virtual environment
└── <track>-playground\           # Track-specific workspace
    ├── docs\                     # Track content (from GitHub)
    ├── theme\                    # Theme files (from GitHub)
    └── mkdocs.yml               # MkDocs configuration
```

## Cleanup

To remove a track playground:
```powershell
Remove-Item -Recurse -Force <track>-playground
```

To remove the virtual environment:
```powershell
Remove-Item -Recurse -Force venv
```

## Files Included

- `setup_local_mkdocs.ps1` - Main PowerShell script
- `setup_local_mkdocs.bat` - Batch file wrapper for easier execution
- `README.md` - This documentation file
