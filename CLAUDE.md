# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose
This repository provides setup scripts to quickly create local development environments for MkDocs documentation sites. It supports multiple documentation tracks (ot, secops, cloud, lanedge, sase) and provides platform-specific scripts for Windows and macOS.

## Key Commands

### Setup and Development

#### Windows
```powershell
# Initial setup (run from windows directory)
./setup_local_mkdocs.bat <track>
# OR
./setup_local_mkdocs.ps1 <track>

# Serve documentation (from <track>-playground directory)
..\venv\Scripts\Activate.ps1
mkdocs serve
```

#### macOS
```bash
# Initial setup (run from macos directory)
./setup_local_mkdocs.sh <track>

# Serve documentation (from <track>-playground directory)
source ../venv/bin/activate
mkdocs serve
```

#### Linux/Ubuntu
```bash
# Initial setup (run from linux directory)
./setup_local_mkdocs.sh <track>

# Serve documentation (from <track>-playground directory)
source ../venv/bin/activate
mkdocs serve

# For remote access (bind to all interfaces)
mkdocs serve --dev-addr 0.0.0.0:8000
```

## Architecture and Structure

### Repository Layout
- **Platform-specific scripts**: Separate directories for `windows/`, `macos/`, and `linux/` containing setup scripts
- **Generated structure**: Scripts create `<track>-playground/` directories containing:
  - `venv/`: Python virtual environment with MkDocs and all required plugins
  - `theme/`: Cloned theme repository from amerintlxperts/theme
  - `docs/`: Track-specific documentation content (git repository)
  - `mkdocs.yml`: Configuration file copied from theme and modified for local development

### Script Workflow
1. **Python validation**: Checks for compatible Python version (3.11 for Windows, 3.9+ for macOS/Linux)
2. **Development tools**: Ensures C++ build tools (Windows), Xcode Command Line Tools (macOS), or build-essential (Linux) are available
3. **Virtual environment**: Creates isolated Python environment with MkDocs and plugins
4. **Repository cloning**: Fetches theme and track-specific documentation
5. **Configuration adjustment**: Modifies mkdocs.yml for local serving (removes environment variables, adjusts paths, removes exporter plugin)
6. **Asset copying**: Copies required theme assets to docs/theme directory

### Key Technical Details
- **MkDocs plugins installed**: material, drawio, exclude, awesome-pages, content-tabs, asciinema-player, macros, github-admonitions, glightbox, literate-nav, material-mark-as-read
- **Git integration**: Documentation directories maintain git repositories for version control
- **Dynamic configuration**: Scripts modify mkdocs.yml to replace environment variables with local paths
- **Platform-specific handling**: 
  - Windows: PowerShell scripts handle Visual C++ tools installation
  - macOS: Bash scripts handle Xcode Command Line Tools
  - Linux: Bash scripts handle build-essential and development packages
- **sed compatibility**: Linux version uses GNU sed syntax (no empty string after -i flag)

## Important Notes
- Scripts require administrator privileges on Windows
- All platforms clone from github.com/amerintlxperts repositories
- The docs directory maintains its git repository for syncing changes with upstream
- For remote access on Linux, use `mkdocs serve --dev-addr 0.0.0.0:8000` instead of default localhost binding
- To kill existing MkDocs process: `lsof -i :8000` to find PID, then `kill <PID>`