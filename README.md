# MkDocs Local Dev Setup

This repository can be used to quickly setup a local dev environment to run your mkdocs site locally.

---

## 🔧 Prerequisites

- Git
- PowerShell (running as administrator)
- ExecutionPolicy set to bypass
- Microsoft Visual C++ 14.0 or greater is required
- Internet access

---

## 🚀 Getting Started

### 1. Clone this setup repo

```bash
git clone https://github.com/amerintlxperts/mkdocs-local-dev.git
cd mkdocs-local-dev
````

### 2. Run the setup

```bash
./setup_local_mkdocs.bat track
```

> Replace `<track>` with your desired track name (ot, secops, cloud, lanedge, sase)

---

## 🌐 View the Docs

After setup:

```powershell
cd <track>-playground
..\venv\Scripts\Activate.ps1
mkdocs serve
```

Then open: [http://localhost:8000](http://localhost:8000)

---

## 🧹 To start fresh

```powershell
Remove-Item -Recurse -Force .\<track>-playground
```

Then re-run the setup.
