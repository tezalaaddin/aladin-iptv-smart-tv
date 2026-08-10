@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_versioned_release.ps1" %*
exit /b %ERRORLEVEL%
