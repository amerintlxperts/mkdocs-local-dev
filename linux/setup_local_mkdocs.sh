#!/bin/bash

# Linux/Ubuntu MkDocs Local Development Setup Script
# Usage: ./setup_local_mkdocs.sh <track>

set -e  # Exit on any error

# === 0. Check Python Version ===
echo "=== Checking Python Installation ==="

# Check for Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo "Found Python: $PYTHON_VERSION"
    
    # Check if it's Python 3.9+ (compatible versions)
    if echo "$PYTHON_VERSION" | grep -qE "Python 3\.(9|1[0-9])\."; then
        echo "Compatible Python version detected - proceeding with setup."
        PYTHON_CMD="python3"
    # Check if it's a beta or pre-release version
    elif echo "$PYTHON_VERSION" | grep -qE "b[0-9]+|rc[0-9]+|a[0-9]+"; then
        echo "ERROR: Beta/pre-release Python detected. This will cause package installation issues."
        echo ""
        echo "Please uninstall the beta version and install a stable Python 3.9+ version:"
        echo "   1. If installed via apt: sudo apt remove python3"
        echo "   2. Install stable Python: sudo apt update && sudo apt install python3 python3-pip python3-venv"
        echo "   3. Or use deadsnakes PPA for specific versions:"
        echo "      sudo add-apt-repository ppa:deadsnakes/ppa"
        echo "      sudo apt update"
        echo "      sudo apt install python3.11 python3.11-venv python3.11-dev"
        echo ""
        echo "Restart terminal and re-run this script after installation."
        echo ""
        exit 1
    else
        echo "ERROR: Python 3.9+ is required for this script."
        echo "Found: $PYTHON_VERSION"
        echo ""
        echo "Please install Python 3.9 or newer:"
        echo "   Option 1 - Via apt (recommended):"
        echo "     sudo apt update"
        echo "     sudo apt install python3 python3-pip python3-venv"
        echo "   Option 2 - Specific version via deadsnakes PPA:"
        echo "     sudo add-apt-repository ppa:deadsnakes/ppa"
        echo "     sudo apt update"
        echo "     sudo apt install python3.11 python3.11-venv python3.11-dev"
        echo ""
        echo "Restart terminal and re-run this script after installation."
        echo ""
        exit 1
    fi
else
    echo "ERROR: No Python installation found."
    echo ""
    echo "Please install Python 3.9+:"
    echo "   sudo apt update"
    echo "   sudo apt install python3 python3-pip python3-venv"
    echo ""
    echo "Or for a specific version:"
    echo "   sudo add-apt-repository ppa:deadsnakes/ppa"
    echo "   sudo apt update"
    echo "   sudo apt install python3.11 python3.11-venv python3.11-dev"
    echo ""
    echo "Restart terminal and re-run this script after installation."
    echo ""
    exit 1
fi

# === 0b. Check for Development Tools (needed for compiling packages like lxml) ===
echo "=== Checking Development Tools ==="

# Check if essential build tools are installed
if ! command -v gcc &> /dev/null || ! command -v make &> /dev/null; then
    echo "Development tools not found."
    echo "Installing essential build tools required for Python packages..."
    echo ""
    echo "This will install build-essential and Python development headers."
    echo "You may be prompted for your sudo password."
    echo ""
    
    # Try to install automatically
    if command -v sudo &> /dev/null; then
        sudo apt update
        sudo apt install -y build-essential python3-dev libxml2-dev libxslt1-dev zlib1g-dev
        echo "Development tools installed successfully."
    else
        echo "Please install the following packages manually:"
        echo "  apt install build-essential python3-dev libxml2-dev libxslt1-dev zlib1g-dev"
        echo ""
        echo "Then re-run this script."
        exit 1
    fi
else
    echo "Development tools found - proceeding."
fi

# === 0c. Check for pip and venv ===
echo "=== Checking pip and venv ==="

# Check if pip is installed
if ! $PYTHON_CMD -m pip --version &> /dev/null; then
    echo "pip not found. Installing pip..."
    if command -v sudo &> /dev/null; then
        sudo apt update
        sudo apt install -y python3-pip
    else
        echo "Please install pip manually:"
        echo "  apt install python3-pip"
        echo "Then re-run this script."
        exit 1
    fi
fi

# Check if venv module is available
if ! $PYTHON_CMD -m venv --help &> /dev/null; then
    echo "venv module not found. Installing python3-venv..."
    if command -v sudo &> /dev/null; then
        sudo apt update
        sudo apt install -y python3-venv
    else
        echo "Please install python3-venv manually:"
        echo "  apt install python3-venv"
        echo "Then re-run this script."
        exit 1
    fi
fi

# === 1. Setup Virtual Environment ===
echo "=== Setting up Virtual Environment ==="

$PYTHON_CMD -m venv venv

if [ ! -f "./venv/bin/activate" ]; then
    echo "ERROR: Virtual environment creation failed. 'activate' script not found."
    exit 1
fi

source ./venv/bin/activate

# === 2. Install MkDocs and Plugins ===
echo "=== Installing MkDocs and Plugins ==="

python -m pip install --upgrade pip
pip install wheel setuptools

# Check Python version for compatibility
PYTHON_VERSION=$(python --version)
echo "Installing packages with Python version: $PYTHON_VERSION"

# Install lxml first (try pre-compiled wheel, fallback to source)
echo "Installing lxml..."
if pip install --only-binary=lxml lxml; then
    echo "lxml installed successfully from pre-compiled wheel."
else
    echo "Pre-compiled wheel not available, trying to install lxml from source..."
    if pip install lxml; then
        echo "lxml installed successfully from source."
    else
        echo "WARNING: lxml installation failed. Some plugins may not work."
    fi
fi

# Install MkDocs and all plugins
echo "Installing MkDocs and plugins..."
pip install mkdocs mkdocs-material \
    mkdocs-drawio mkdocs-drawio-exporter \
    mkdocs-exclude mkdocs-awesome-pages-plugin \
    mkdocs-content-tabs mkdocs-asciinema-player \
    mkdocs-macros-plugin mkdocs-github-admonitions-plugin \
    mkdocs-glightbox mkdocs-literate-nav \
    mkdocs-material-mark-as-read

# === 3. Clone Repos ===
echo "=== Cloning Repositories ==="

TRACK=$1
if [ -z "$TRACK" ]; then
    echo "ERROR: Usage: $0 <track>"
    echo "Available tracks: ot, secops, cloud, lanedge, sase"
    exit 1
fi

mkdir -p "$TRACK-playground"
cd "$TRACK-playground"

# Clone the theme repository
echo "Cloning theme repository..."
if ! git clone https://github.com/amerintlxperts/theme.git; then
    echo "ERROR: Failed to clone theme repository."
    echo "Please check your internet connection and GitHub access."
    exit 1
fi

# Create docs directory and clone track content directly into it
echo "Cloning $TRACK documentation..."
mkdir -p "docs"
cd docs
if ! git clone https://github.com/amerintlxperts/$TRACK.git .; then
    echo "ERROR: Failed to clone $TRACK repository."
    echo "Please verify that the track name '$TRACK' is correct."
    echo "Available tracks: ot, secops, cloud, lanedge, sase"
    cd ..
    exit 1
fi
# Keep the git repository so we can sync changes later
cd ..

# === 4. Setup Docs Structure ===
echo "=== Setting up Documentation Structure ==="

# Copy mkdocs.yml from theme
if [ -f "theme/mkdocs.yml" ]; then
    cp theme/mkdocs.yml .
else
    echo "ERROR: mkdocs.yml not found in theme directory"
    exit 1
fi

# === Add landing-page.css to docs/ ===
cat > docs/landing-page.css << 'EOF'
.md-typeset h1 {
  visibility: hidden;
}
EOF

# === 5. Adjust mkdocs.yml for Local Serve ===
echo "=== Configuring mkdocs.yml for local development ==="

# Use sed for text replacement (Linux/GNU sed compatible)
# Note: Linux sed doesn't need empty '' after -i
sed -i 's/custom_dir: !ENV \[CUSTOM_DIR, ".*"\]/custom_dir: theme/' mkdocs.yml
sed -i 's|docs/theme/covers/stylesheets/pdf.scss|theme/covers/stylesheets/pdf.scss|' mkdocs.yml

# === 5b. Remove 'exporter' plugin block from mkdocs.yml ===
# Use awk to remove the exporter plugin block
awk '
BEGIN { in_exporter = 0 }
/^  - exporter:/ { in_exporter = 1; next }
/^  - / && in_exporter { in_exporter = 0 }
/^[^ ]/ && in_exporter { in_exporter = 0 }
!in_exporter || /^  - /
' mkdocs.yml > mkdocs.yml.tmp && mv mkdocs.yml.tmp mkdocs.yml

# === Copy required theme assets to docs/theme ===
echo "=== Copying theme assets ==="

THEME_ASSETS=(
    "extra.css"
    "XpertsSummitBanner.png"
    "XpertsSummitBanner-dark.png"
    "favicon.ico"
)

SOURCE_THEME="theme"
DEST_THEME="docs/theme"
mkdir -p "$DEST_THEME"

for asset in "${THEME_ASSETS[@]}"; do
    if [ -f "$SOURCE_THEME/$asset" ]; then
        cp "$SOURCE_THEME/$asset" "$DEST_THEME/" 2>/dev/null || true
    fi
done

# === 6. Complete ===
echo ""
echo "========================================="
echo "Setup complete!"
echo "========================================="
echo ""
echo "To serve your docs:"
echo ""
echo "    cd $TRACK-playground"
echo "    source ../venv/bin/activate"
echo "    mkdocs serve"
echo ""
echo "Then open: http://localhost:8000"
echo ""
echo "To sync changes from the main repository later:"
echo ""
echo "    cd $TRACK-playground/docs"
echo "    git pull origin main"
echo "    cd .."
echo "    mkdocs serve"
echo ""
echo "To stop the server: Press Ctrl+C"
echo ""