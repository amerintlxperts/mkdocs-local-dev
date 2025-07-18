@echo off
powershell -ExecutionPolicy Bypass -NoProfile -Command "& '%~dp0setup_local_mkdocs.ps1' %1"
