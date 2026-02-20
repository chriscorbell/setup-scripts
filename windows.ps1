# Need to disable UAC first
Write-Host "Press any key to open UAC settings, then disable UAC by changing the slider to 'Never notify'" -ForegroundColor Cyan
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null
useraccountcontrolsettings
Write-Host "Confirm UAC is disabled, then press any key to continue" -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null

# Set execution policy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# Define function for setting registry keys
function Set-DwordReg($KeyPath, $Name, $Value) {
    reg.exe add $KeyPath /v $Name /t REG_DWORD /d $Value /f | Out-Null
}

# Remove all pinned apps from taskbar
$taskbarPins = Join-Path $env:APPDATA "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
if (Test-Path $taskbarPins) {
    Remove-Item -Path (Join-Path $taskbarPins "*") -Force -ErrorAction SilentlyContinue
}

# Also try deleting Taskband state (may not exist on newer builds)
reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f 2>$null | Out-Null

# Search = Hide (plus cache)
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarModeCache" 1

# Task View off / Widgets off
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0

# Start: More pins
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_Layout" 1

# Start: disable “recently added”
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Start" "ShowRecentList" 0

# Start/Explorer/Jump lists: disable recents
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackDocs" 0

# Start: disable websites from browsing history (policy)
Set-DwordReg "HKCU\Software\Policies\Microsoft\Windows\Explorer" "HideRecommendedPersonalizedSites" 1

# Start: disable “tips/shortcuts/new apps”
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_IrisRecommendations" 0

# Start: disable account notifications
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_AccountNotifications" 0

# Explorer: compact view + file extensions
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "UseCompactMode" 1
Set-DwordReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

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
