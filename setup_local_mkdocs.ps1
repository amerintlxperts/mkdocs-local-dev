# Requires: Run as Administrator
$ErrorActionPreference = "Stop"

# === 0. Check and Install Python ===
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python not found. Installing Python..."
    $installer = "$env:TEMP\python-installer.exe"
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe" -OutFile $installer
    Start-Process -FilePath $installer -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
    Remove-Item $installer
    Write-Host "Python installed. You may need to restart PowerShell if 'python' is still not recognized."
}

# === 1. Setup Virtual Environment ===
python -m venv venv
.\venv\Scripts\Activate.ps1

# === 2. Install MkDocs and Plugins ===
python -m pip install --upgrade pip
pip install mkdocs mkdocs-material `
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
}

New-Item -ItemType Directory -Force -Path "playground"
Set-Location playground

git clone https://github.com/amerintlxperts/theme
git clone https://github.com/amerintlxperts/$track

# === 4. Setup Docs Structure ===
Set-Location $track

# Copy mkdocs.yml from theme
Copy-Item ../theme/mkdocs.yml .

# Create docs folder
New-Item -ItemType Directory -Force -Path "docs"

# Move everything except .git and docs into docs/
Get-ChildItem -Force | Where-Object {
    $_.Name -ne "docs" -and $_.Name -ne ".git"
} | ForEach-Object {
    Move-Item -Path $_.FullName -Destination "docs" -Force
}

# Move mkdocs.yml back to project root
Move-Item docs\mkdocs.yml . -Force

# === Add landing-page.css to docs/ ===
$landingCssPath = "docs\landing-page.css"
@"
.md-typeset h1 {
  visibility: hidden;
}
"@ | Set-Content -Encoding UTF8 $landingCssPath


# === 5. Adjust mkdocs.yml for Local Serve ===
(Get-Content mkdocs.yml) `
    -replace 'custom_dir: !ENV \[CUSTOM_DIR, ".*?"\]', 'custom_dir: ../theme' `
    -replace 'docs/theme/covers/stylesheets/pdf.scss', '../theme/covers/stylesheets/pdf.scss' `
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

$sourceTheme = "..\theme"
$destTheme = "docs\theme"
New-Item -ItemType Directory -Force -Path $destTheme | Out-Null

foreach ($asset in $themeAssets) {
    Copy-Item -Path (Join-Path $sourceTheme $asset) -Destination $destTheme -Force -ErrorAction SilentlyContinue
}


# === 6. Complete ===
Write-Host "`n✅ Setup complete."
Write-Host "To serve your docs:"
Write-Host "`n    cd playground\$track"
Write-Host "    ..\..\venv\Scripts\Activate.ps1"
Write-Host "    mkdocs serve`n"


