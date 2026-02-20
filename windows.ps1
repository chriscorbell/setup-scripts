# Need to disable UAC first
Write-Host "Press any key to open UAC settings, then disable UAC by changing the slider to 'Never notify'" -ForegroundColor Cyan
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null
useraccountcontrolsettings
Write-Host "Confirm UAC is disabled, then press any key to continue" -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null

# Set Dark Theme
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0

# Remove bloat
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

# Update source
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
$env:Path = "C:\Program Files\starship\bin;$env:Path"
winget install ajeetdsouza.zoxide --accept-source-agreements --accept-package-agreements
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

# Pull Starship config
New-Item -ItemType Directory -Path "$HOME\.config" -Force | Out-Null; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chriscorbell/dotfiles/refs/heads/main/.config/starship.toml" -OutFile "$HOME\.config\starship.toml"

# Pull PowerShell profile
New-Item -ItemType Directory -Path "$HOME\Documents\PowerShell" -Force | Out-Null; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chriscorbell/dotfiles-windows/refs/heads/main/Microsoft.PowerShell_profile.ps1" -OutFile "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
New-Item -ItemType Directory -Path "$HOME\Documents\WindowsPowerShell" -Force | Out-Null; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chriscorbell/dotfiles-windows/refs/heads/main/Microsoft.PowerShell_profile.ps1" -OutFile "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# Install Bun
powershell -c "irm bun.sh/install.ps1|iex"

# Install uv + python
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
$env:Path = "$HOME\.local\bin;$env:Path"
uv python install

# Restore classic right-click menu
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
