# MkDocs Local Dev Setup

This repository provides scripts to quickly setup a local development environment for MkDocs documentation sites.

---

## 🔧 Prerequisites

### Windows
- Git
- PowerShell (running as administrator)
- ExecutionPolicy set to bypass (`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`)
- Microsoft Visual C++ 14.0 or greater
- Internet access

### macOS
- Git
- Python 3.9+ (3.11 recommended)
- Xcode Command Line Tools (will be prompted to install if missing)
- Internet access

---

## 🚀 Getting Started

### 1. Clone this setup repo

```bash
git clone https://github.com/amerintlxperts/mkdocs-local-dev.git
cd mkdocs-local-dev
```

### 2. Run the setup

#### Windows
```bash
cd windows
./setup_local_mkdocs.bat <track>
```

#### macOS
```bash
cd macos
./setup_local_mkdocs.sh <track>
```

> Replace `<track>` with your desired track name (ot, secops, cloud, lanedge, sase)

---

## 🌐 View the Docs

After setup:

#### Windows
```powershell
cd <track>-playground
..\venv\Scripts\Activate.ps1
mkdocs serve
```

#### macOS
```bash
cd <track>-playground
source ../venv/bin/activate
mkdocs serve
```

Then open: [http://localhost:8000](http://localhost:8000)

---

## 📝 Working with the Documentation

The `<track>-playground/docs/` directory is a fully functional git repository. You can:

- Edit files directly in the docs directory
- Commit changes: `git add .` and `git commit -m "Your message"`
- Push to remote: `git push origin main`
- Pull latest changes: `git pull origin main`

---

## 🧹 To start fresh

#### Windows
```powershell
Remove-Item -Recurse -Force .\<track>-playground
```

#### macOS
```bash
rm -rf <track>-playground
```

Then re-run the setup.
