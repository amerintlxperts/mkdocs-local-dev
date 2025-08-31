#!/bin/bash

# macOS MkDocs Local Development Setup Script
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
        echo "   1. If installed via Homebrew: brew uninstall python (check with 'brew list | grep python')"
        echo "   2. If installed via python.org: Use the Python installer's uninstall option"
        echo "   3. Install stable Python via Homebrew: brew install python@3.11"
        echo "   4. Or download from: https://www.python.org/downloads/"
        echo ""
        echo "Restart terminal and re-run this script after installation."
        echo ""
        exit 1
    else
        echo "ERROR: Python 3.9+ is required for this script."
        echo "Found: $PYTHON_VERSION"
        echo ""
        echo "Please install Python 3.9 or newer:"
        echo "   Option 1 - Via Homebrew (recommended):"
        echo "     brew install python@3.13"
        echo "   Option 2 - Direct download:"
        echo "     Download from: https://www.python.org/downloads/"
        echo ""
        echo "Restart terminal and re-run this script after installation."
        echo ""
        exit 1
    fi
else
    echo "ERROR: No Python installation found."
    echo ""
    echo "Please install Python 3.9+:"
    echo "   Option 1 - Via Homebrew (recommended):"
    echo "     /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "     brew install python@3.13"
    echo "   Option 2 - Direct download:"
    echo "     Download from: https://www.python.org/downloads/"
    echo ""
    echo "Restart terminal and re-run this script after installation."
    echo ""
    exit 1
fi

# === 0b. Check for Developer Tools (needed for compiling packages like lxml) ===
echo "=== Checking Developer Tools ==="

if ! command -v gcc &> /dev/null; then
    echo "Xcode Command Line Tools not found."
    echo "These are needed to compile Python packages that don't have pre-built wheels."
    echo "Installing Xcode Command Line Tools..."
    echo ""
    echo "You will be prompted to install Xcode Command Line Tools."
    echo "This is required for lxml and other packages to compile properly."
    xcode-select --install
    echo ""
    echo "Please complete the Xcode Command Line Tools installation and re-run this script."
    echo ""
    exit 1
else
    echo "Developer tools found - proceeding."
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
    exit 1
fi

mkdir -p "$TRACK-playground"
cd "$TRACK-playground"

# Clone the theme repository
git clone https://github.com/amerintlxperts/theme.git

# Create docs directory and clone track content directly into it
mkdir -p "docs"
cd docs
git clone https://github.com/amerintlxperts/$TRACK.git .
# Keep the git repository so we can sync changes later
cd ..

# === 4. Setup Docs Structure ===
echo "=== Setting up Documentation Structure ==="

# Copy mkdocs.yml from theme
cp theme/mkdocs.yml .

# === Add landing-page.css to docs/ ===
cat > docs/landing-page.css << 'EOF'
.md-typeset h1 {
  visibility: hidden;
}
EOF

# === 5. Adjust mkdocs.yml for Local Serve ===
echo "=== Configuring mkdocs.yml for local development ==="

# Use sed for text replacement (macOS compatible)
sed -i '' 's/custom_dir: !ENV \[CUSTOM_DIR, ".*"\]/custom_dir: theme/' mkdocs.yml
sed -i '' 's|docs/theme/covers/stylesheets/pdf.scss|theme/covers/stylesheets/pdf.scss|' mkdocs.yml

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
echo "Setup complete!"
echo "To serve your docs:"
echo ""
echo "    cd $TRACK-playground"
echo "    source ../venv/bin/activate"
echo "    mkdocs serve"
echo ""
echo "To sync changes from the main repository later:"
echo ""
echo "    cd $TRACK-playground/docs"
echo "    git pull origin main"
echo "    cd .."
echo "    mkdocs serve"
echo ""
