# Requires -RunAsAdministrator

Write-Host "Stopping known AVG and CCleaner services..." -ForegroundColor Cyan
$Services = @("AvgWscReporter", "AvgVrtFlt", "AvgAsv", "ccleaner_performance_keeper")
foreach ($Service in $Services) {
    if (Get-Service -Name $Service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $Service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $Service -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

Write-Host "Uninstalling AVG Software..." -ForegroundColor Cyan
# Query Registry for AVG Uninstall Strings (Both 32-bit and 64-bit paths)
$AvgApps = Get-ChildItem -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | 
    Get-ItemProperty | 
    Where-Object { $_.DisplayName -like "*AVG*" }

foreach ($App in $AvgApps) {
    Write-Host "Uninstalling: $($App.DisplayName)" -ForegroundColor Yellow
    if ($App.UninstallString -like "msiexec*") {
        $Args = $App.UninstallString -replace "msiexec.exe", "" -replace "/I", "/X"
        Start-Process msiexec.exe -ArgumentList "$Args /qn /norestart" -Wait -NoNewWindow
    } else {
        # Fallback for executable uninstallers; adding silent flags if known
        $Uninstaller = ($App.UninstallString -split '"')[1]
        if (-not $Uninstaller) { $Uninstaller = ($App.UninstallString -split ' ')[0] }
        Start-Process $Uninstaller -ArgumentList "/silent /verysilent /suppressmsgboxes /norestart" -Wait -NoNewWindow -ErrorAction SilentlyContinue
    }
}

Write-Host "Uninstalling CCleaner..." -ForegroundColor Cyan
$CCleanerApps = Get-ChildItem -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | 
    Get-ItemProperty | 
    Where-Object { $_.DisplayName -like "*CCleaner*" }

foreach ($App in $CCleanerApps) {
    Write-Host "Uninstalling: $($App.DisplayName)" -ForegroundColor Yellow
    if ($App.UninstallString) {
        $Uninstaller = ($App.UninstallString -split '"')[1]
        if (-not $Uninstaller) { $Uninstaller = ($App.UninstallString -split ' ')[0] }
        # CCleaner's uninstaller executable accepts a /S flag for silent removal
        Start-Process $Uninstaller -ArgumentList "/S" -Wait -NoNewWindow -ErrorAction SilentlyContinue
    }
}

Write-Host "Uninstallation processes complete. A reboot is highly recommended." -ForegroundColor Green
