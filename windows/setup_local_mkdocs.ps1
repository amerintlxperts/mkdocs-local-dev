# Requires: Run as Administrator
$ErrorActionPreference = "Stop"

# === 0. Check Python Version ===
$pythonVersion = $null

# Check for Python
$pythonExe = Get-Command python -ErrorAction SilentlyContinue
if ($pythonExe) {
    $pythonVersion = python --version 2>$null
    if ($pythonVersion) {
        Write-Host "Found Python: $pythonVersion"
        
        # Check if it's Python 3.11.x
        if ($pythonVersion -match "Python 3\.11\.\d+") {
            Write-Host "Python 3.11 detected - proceeding with setup."
        } 
        # Check if it's a beta or pre-release version
        elseif ($pythonVersion -match "b\d+|rc\d+|a\d+") {
            Write-Host "ERROR: Beta/pre-release Python detected. This will cause package installation issues."
            Write-Host ""
            Write-Host "Please uninstall the beta version and install Python 3.11:"
            Write-Host "   1. Go to Settings > Apps > Apps & features"
            Write-Host "   2. Search for 'Python' and uninstall any beta versions"
            Write-Host "   3. Download Python 3.11 from: https://www.python.org/downloads/release/python-3115/"
            Write-Host "   4. Install with 'Add to PATH' option checked"
            Write-Host ""
            Write-Host "Restart PowerShell and re-run this script after installation."
            Write-Host ""
            exit 1
        }
        else {
            Write-Host "ERROR: Python 3.11 is required for this script."
            Write-Host "Found: $pythonVersion"
            Write-Host ""
            Write-Host "Please install Python 3.11:"
            Write-Host "   1. Download from: https://www.python.org/downloads/release/python-3115/"
            Write-Host "   2. Install with 'Add to PATH' option checked"
            Write-Host "   3. Restart PowerShell and re-run this script"
            Write-Host ""
            exit 1
        }
    } else {
        Write-Host "ERROR: Python command found but version check failed."
        Write-Host "Please ensure Python 3.11 is properly installed and accessible."
        exit 1
    }
} else {
    Write-Host "ERROR: No Python installation found."
    Write-Host ""
    Write-Host "Please install Python 3.11:"
    Write-Host "   1. Download from: https://www.python.org/downloads/release/python-3115/"
    Write-Host "   2. Install with 'Add to PATH' option checked"
    Write-Host "   3. Restart PowerShell and re-run this script"
    Write-Host ""
    exit 1
}

# === 0c. Check and Install Visual Studio C++ Build Tools ===
$vcRedistInstalled = $false
$vcBuildToolsInstalled = $false

# Check for Visual C++ Redistributable
$vcRedistKeys = @(
    "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
    "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x86"
)

foreach ($key in $vcRedistKeys) {
    if (Test-Path $key) {
        $vcRedistInstalled = $true
        break
    }
}

# Check for Build Tools (look for cl.exe or MSBuild)
$buildToolsPaths = @(
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe"
)

foreach ($path in $buildToolsPaths) {
    if (Test-Path $path) {
        $vcBuildToolsInstalled = $true
        break
    }
}

if (-not $vcRedistInstalled -and -not $vcBuildToolsInstalled) {
    Write-Host "Visual C++ Build Tools not found. Installing Microsoft C++ Build Tools..."
    $buildToolsInstaller = "$env:TEMP\vs_buildtools.exe"
    Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_buildtools.exe" -OutFile $buildToolsInstaller
    Start-Process -FilePath $buildToolsInstaller -ArgumentList "--quiet", "--wait", "--add", "Microsoft.VisualStudio.Workload.VCTools", "--includeRecommended" -Wait
    Remove-Item $buildToolsInstaller
    Write-Host "Visual C++ Build Tools installed."
}

# === 1. Setup Virtual Environment ===
python -m venv venv

if (-not (Test-Path .\venv\Scripts\Activate.ps1)) {
    Write-Error "Virtual environment creation failed. 'Activate.ps1' not found."
    exit 1
}

.\venv\Scripts\Activate.ps1


# === 2. Install MkDocs and Plugins ===
python -m pip install --upgrade pip
pip install wheel setuptools

# Check Python version for compatibility
$pythonVersion = python --version
Write-Host "Installing packages with Python version: $pythonVersion"

# Install lxml first (try pre-compiled wheel, fallback to source)
try {
    pip install --only-binary=lxml lxml
    Write-Host "lxml installed successfully from pre-compiled wheel."
} catch {
    Write-Host "Pre-compiled wheel not available, trying to install lxml from source..."
    try {
        pip install lxml
        Write-Host "lxml installed successfully from source."
    } catch {
        Write-Host "WARNING: lxml installation failed. Some plugins may not work."
    }
}

# Install MkDocs and all plugins
Write-Host "Installing MkDocs and plugins..."
pip install mkdocs mkdocs-material `
    pymdown-extensions `
    mkdocs-drawio mkdocs-drawio-exporter `
    mkdocs-exclude mkdocs-awesome-pages-plugin `
    mkdocs-content-tabs mkdocs-asciinema-player `
    mkdocs-macros-plugin mkdocs-github-admonitions-plugin `
    mkdocs-glightbox mkdocs-literate-nav `
    mkdocs-material-mark-as-read


# === 3. Clone Repos ===
$track = $args[0]
if (-not $track) {
    Write-Error "Usage: .\setup_local_mkdocs.ps1 <track>"
    exit 1
}

New-Item -ItemType Directory -Force -Path "$track-playground"
Set-Location "$track-playground"

# Clone the theme repository
git clone https://github.com/amerintlxperts/theme.git

# Create docs directory and clone track content directly into it
New-Item -ItemType Directory -Force -Path "docs"
Set-Location docs
git clone https://github.com/amerintlxperts/$track.git .
Set-Location ..

# === 4. Setup Docs Structure ===

# Copy mkdocs.yml from theme
Copy-Item theme/mkdocs.yml .

# === Add landing-page.css to docs/ ===
$landingCssPath = "docs\landing-page.css"
@"
.md-typeset h1 {
  visibility: hidden;
}
"@ | Set-Content -Encoding UTF8 $landingCssPath


# === 5. Adjust mkdocs.yml for Local Serve ===
(Get-Content mkdocs.yml) `
    -replace 'custom_dir: !ENV \[CUSTOM_DIR, ".*?"\]', 'custom_dir: theme' `
    -replace 'docs/theme/covers/stylesheets/pdf.scss', 'theme/covers/stylesheets/pdf.scss' `
    | Set-Content mkdocs.yml

# === 5b. Remove 'exporter' plugin block from mkdocs.yml ===
$mkdocs = Get-Content mkdocs.yml -Raw
# Remove entire '- exporter:' block and its indentation
$mkdocs = $mkdocs -replace "(?ms)^  - exporter:\s*.*?^(?=  -|\Z)", ""
$mkdocs | Set-Content mkdocs.yml

# === Copy required theme assets to docs/theme ===
$themeAssets = @(
    "extra.css",
    "XpertsSummitBanner.png",
    "XpertsSummitBanner-dark.png",
    "favicon.ico"
)

$sourceTheme = "theme"
$destTheme = "docs\theme"
New-Item -ItemType Directory -Force -Path $destTheme | Out-Null

foreach ($asset in $themeAssets) {
    Copy-Item -Path (Join-Path $sourceTheme $asset) -Destination $destTheme -Force -ErrorAction SilentlyContinue
}


# === 6. Complete ===
Write-Host "`nSetup complete."
Write-Host "To serve your docs:"
Write-Host "`n    cd $track-playground"
Write-Host "    ..\venv\Scripts\Activate.ps1"
Write-Host "    mkdocs serve`n"



