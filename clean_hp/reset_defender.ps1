# Requires -RunAsAdministrator

Write-Host "Enabling and resetting Windows Defender features to default..." -ForegroundColor Cyan

# 1. Enable Real-Time and Behavioral Protection Modules
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableIOAVProtection $false
Set-MpPreference -DisableOnAccessProtection $false
Set-MpPreference -DisableScriptScanning $false
Set-MpPreference -DisableBlockAtFirstSeen $false

# 2. Set Cloud Protection to High/Default levels
Set-MpPreference -MAPSReporting Advanced
Set-MpPreference -SubmitSamplesConsent SendSafeSamples

# 3. Enable PUA (Potentially Unwanted Application) Protection
Set-MpPreference -PUAProtection Enabled

# 4. Restart the Defender Service to apply configurations
Write-Host "Restarting Windows Defender Threat Protection Service..." -ForegroundColor Yellow
Restart-Service -Name WinDefend -Force

# Verify Status
Get-MpComputerStatus | Select-Object AMRunningMode, RealTimeProtectionEnabled, PUAProtectionEnabled
