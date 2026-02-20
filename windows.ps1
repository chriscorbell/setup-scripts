# Need to auto-elevate privileges if needed
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Start-Process powershell -Verb RunAs -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-Command', "irm https://raw.githubusercontent.com/chriscorbell/setup-scripts/main/windows.ps1 | iex"
    )
    exit
}

# Set execution policy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# Define function for setting registry keys
function Set-Dword($Path, $Name, $Value) {
    New-Item -Path $Path -Force | Out-Null
    New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
}

# Remove all pinned apps from taskbar
# Taskband key may be missing in newer Windows 11 builds, so handle both cases: https://www.elevenforum.com/t/reset-and-clear-pinned-items-on-taskbar-in-windows-11.3634
$taskbarPins = Join-Path $env:APPDATA "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
if (Test-Path $taskbarPins) {
    Remove-Item -Path (Join-Path $taskbarPins "*") -Force -ErrorAction SilentlyContinue
}

$taskbandKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
if (Test-Path $taskbandKey) {
    Remove-Item -Path $taskbandKey -Recurse -Force -ErrorAction SilentlyContinue
}

# Taskbar: Search = Hide (plus Cache to prevent Windows re-migrating defaults)
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarModeCache" 1
# SearchboxTaskbarMode + Cache behavior documented here: https://awakecoding.com/posts/disabling-the-windows-11-taskbar-search-box-for-all-users/)[3](https://learn.microsoft.com/en-us/answers/questions/1726171/trying-to-hid-the-search-bar-for-all-users-using-r

# Taskbar: Task View = Off
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0

# Taskbar: Widgets = Off
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0

# Start: Layout = More pins (1)
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_Layout" 1

# Start: Disable “Show recently added apps”
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" "ShowRecentList" 0

# Start/Explorer/Jump Lists: Disable “recommended files / recents”
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackDocs" 0

# Start: Disable “websites from browsing history” (policy)
Set-Dword "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "HideRecommendedPersonalizedSites" 1

# Start: Disable “tips/shortcuts/new apps recommendations”
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_IrisRecommendations" 0

# Start: Disable “account-related notifications”
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_AccountNotifications" 0

# File Explorer: Enable compact view
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "UseCompactMode" 1

# File Explorer: Show file extensions
Set-Dword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# Restore classic right-click menu
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve

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
