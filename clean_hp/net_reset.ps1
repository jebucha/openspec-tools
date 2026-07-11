# Requires -RunAsAdministrator

Write-Host "Releasing existing IP configurations..." -ForegroundColor Cyan
ipconfig /release

Write-Host "Flushing and rebuilding DNS Cache..." -ForegroundColor Cyan
ipconfig /flushdns

Write-Host "Resetting Winsock catalog (removes leftover AV network hooks)..." -ForegroundColor Cyan
netsh winsock reset

Write-Host "Resetting TCP/IP stack to factory defaults..." -ForegroundColor Cyan
netsh int ip reset

Write-Host "Ensuring DHCP Client Service is set to start automatically..." -ForegroundColor Cyan
Set-Service -Name "Dhcp" -StartupType Automatic
Start-Service -Name "Dhcp" -ErrorAction SilentlyContinue

Write-Host "Network reset complete. You MUST reboot to bind the default Windows drivers." -ForegroundColor Green