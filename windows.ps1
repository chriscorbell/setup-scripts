# Need to auto-elevate privileges if needed
# $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
# ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# if (-not $IsAdmin) {
#     Start-Process powershell -Verb RunAs -ArgumentList @(
#         '-NoProfile',
#         '-ExecutionPolicy', 'Bypass',
#         '-Command', "irm https://raw.githubusercontent.com/chriscorbell/setup-scripts/main/windows.ps1 | iex"
#     )
#     exit
# }

# Disable UAC
Write-Host "Press any key to open UAC settings, then disable UAC by changing the slider to 'Never notify'" -ForegroundColor Cyan
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null
useraccountcontrolsettings
Start-Sleep -Milliseconds 2000
Write-Host "Confirm UAC is disabled, then press any key to continue" -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null

# Set execution policy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# Remove all pinned apps from taskbar
$taskbarPins = Join-Path $env:APPDATA "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
if (Test-Path $taskbarPins) {
    Remove-Item -Path (Join-Path $taskbarPins "*") -Force -ErrorAction SilentlyContinue
}

# Also try deleting Taskband state (may not exist on newer builds)
reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f 2>$null | Out-Null

# Search = Hide (plus cache)
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode"      /t REG_DWORD /d 0 /f | Out-Null
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarModeCache" /t REG_DWORD /d 1 /f | Out-Null

# Task View off
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d 0 /f | Out-Null

# Widgets off
reg.exe add "HKLM\Software\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f | Out-Null

# Start: More pins
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_Layout" /t REG_DWORD /d 1 /f | Out-Null

# Start: disable “recently added”
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Start" /v "ShowRecentList" /t REG_DWORD /d 0 /f | Out-Null

# Start/Explorer/Jump lists: disable recents
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0 /f | Out-Null

# Start: disable websites from browsing history (policy)
reg.exe add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedPersonalizedSites" /t REG_DWORD /d 1 /f | Out-Null

# Start: disable “tips/shortcuts/new apps”
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_IrisRecommendations" /t REG_DWORD /d 0 /f | Out-Null

# Start: disable account notifications
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_AccountNotifications" /t REG_DWORD /d 0 /f | Out-Null

# Explorer: compact view + file extensions
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "UseCompactMode" /t REG_DWORD /d 1 /f | Out-Null
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt"    /t REG_DWORD /d 0 /f | Out-Null

# Apply changes: restart Explorer
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 800
Start-Process explorer.exe

# Remove bloatware
Get-AppxPackage -Name "Clipchamp.Clipchamp" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.BingNews" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.BingWeather" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.GamingApp" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.GetHelp" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.MicrosoftStickyNotes" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.OutlookForWindows" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.PowerAutomateDesktop" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.Todos" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.Windows.DevHome" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.WindowsAlarms" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.WindowsCamera" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.WindowsFeedbackHub" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.YourPhone" | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.ZuneMusic" | Remove-AppxPackage
Get-AppxPackage -Name "MicrosoftCorporationII.QuickAssist" | Remove-AppxPackage
winget remove Microsoft.Teams

# Update winget sources
winget source update

# Update existing apps
winget upgrade --all --accept-source-agreements --accept-package-agreements

# Install new apps
winget install 7zip.7zip --accept-source-agreements --accept-package-agreements
winget install Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
winget install Microsoft.PowerShell --accept-source-agreements --accept-package-agreements
winget install 9N1F85V9T8BN --accept-source-agreements --accept-package-agreements
winget install Microsoft.Teams --accept-source-agreements --accept-package-agreements
winget install Microsoft.Office --accept-source-agreements --accept-package-agreements
winget install Starship.Starship --accept-source-agreements --accept-package-agreements
winget install ajeetdsouza.zoxide --accept-source-agreements --accept-package-agreements
winget install DEVCOM.JetBrainsMonoNerdFont --accept-source-agreements --accept-package-agreements
winget install CrystalDewWorld.CrystalDiskInfo --accept-source-agreements --accept-package-agreements
winget install CrystalDewWorld.CrystalDiskMark --accept-source-agreements --accept-package-agreements
winget install ImputNet.Helium --accept-source-agreements --accept-package-agreements
winget install Zen-Team.Zen-Browser --accept-source-agreements --accept-package-agreements
winget install Google.Chrome --accept-source-agreements --accept-package-agreements
winget install RaspberryPiFoundation.RaspberryPiImager --accept-source-agreements --accept-package-agreements
winget install Audacity.Audacity --accept-source-agreements --accept-package-agreements
winget install TGRMNSoftware.BulkRenameUtility --accept-source-agreements --accept-package-agreements
winget install REALiX.HWiNFO --accept-source-agreements --accept-package-agreements
winget install LocalSend.LocalSend --accept-source-agreements --accept-package-agreements
winget install Discord.Discord --accept-source-agreements --accept-package-agreements
winget install Bambulab.Bambustudio --accept-source-agreements --accept-package-agreements
winget install OBSProject.OBSStudio --accept-source-agreements --accept-package-agreements
winget install MPC-BE.MPC-BE --accept-source-agreements --accept-package-agreements
winget install ente-io.auth-desktop --accept-source-agreements --accept-package-agreements
winget install Proton.ProtonVPN --accept-source-agreements --accept-package-agreements
winget install Valve.Steam --accept-source-agreements --accept-package-agreements
winget install Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements
winget install MOTU.MSeries --accept-source-agreements --accept-package-agreements
winget install Tailscale.Tailscale --accept-source-agreements --accept-package-agreements
winget install Microsoft.PowerToys --accept-source-agreements --accept-package-agreements
winget install Adobe.CreativeCloud --accept-source-agreements --accept-package-agreements
winget remove Microsoft.OneDrive
winget remove Microsoft.CommandPalette

# Install WSL2
wsl --install --no-distribution

# Temporarily set PATH
$env:Path = "$HOME\.local\bin;$HOME\AppData\Local\Microsoft\WinGet\Packages\ajeetdsouza.zoxide_Micorosft.Winget.Source_8wekyb3d8bbwe;C:\Program Files\starship\bin;$env:Path"

# Pull Starship config
New-Item -ItemType Directory -Path "$HOME\.config" -Force | Out-Null; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chriscorbell/dotfiles/main/.config/starship.toml" -OutFile "$HOME\.config\starship.toml"

# Pull PowerShell profile
New-Item -ItemType Directory -Path "$HOME\Documents\PowerShell" -Force | Out-Null; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chriscorbell/dotfiles-windows/main/Microsoft.PowerShell_profile.ps1" -OutFile "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
New-Item -ItemType Directory -Path "$HOME\Documents\WindowsPowerShell" -Force | Out-Null; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chriscorbell/dotfiles-windows/main/Microsoft.PowerShell_profile.ps1" -OutFile "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# Pull Windows Terminal config
New-Item -ItemType Directory -Path "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" -Force | Out-Null; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chriscorbell/dotfiles-windows/main/settings.json" -OutFile "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Install Bun
powershell -c "irm bun.sh/install.ps1|iex"

# Install uv + python
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
uv python install
