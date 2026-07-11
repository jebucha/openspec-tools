# Requires -RunAsAdministrator

Write-Host "1/3: Checking local system image health via DISM..." -ForegroundColor Cyan
DISM /Online /Cleanup-Image /CheckHealth

Write-Host "2/3: Repairing local system image via DISM (Downloading pristine files if needed)..." -ForegroundColor Cyan
DISM /Online /Cleanup-Image /RestoreHealth

Write-Host "3/3: Running System File Checker..." -ForegroundColor Cyan
sfc /scannow

Write-Host "System integrity scan complete." -ForegroundColor Green