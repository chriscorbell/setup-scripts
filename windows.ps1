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
winget remove Microsoft.OneDrive
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

# Update existing apps
winget upgrade --all

# Install new apps
winget install 7zip.7zip
winget install Gyan.FFmpeg
winget install 9N1F85V9T8BN
winget install Microsoft.Teams
winget install Microsoft.Office
winget install Starship.Starship
winget install ajeetdsouza.zoxide
winget install CrystalDewWorld.CrystalDiskInfo
winget install CrystalDewWorld.CrystalDiskMark
winget install ImputNet.Helium
winget install Zen-Team.Zen-Browser
winget install Google.Chrome
winget install RaspberryPiFoundation.RaspberryPiImager
winget install Audacity.Audacity
winget install TGRMNSoftware.BulkRenameUtility
winget install REALiX.HWiNFO
winget install LocalSend.LocalSend
winget install Discord.Discord
winget install Bambulab.Bambustudio
winget install OBSProject.OBSStudio
winget install MPC-BE.MPC-BE
winget install ente-io.auth-desktop
winget install Proton.ProtonVPN
winget install Valve.Steam
winget install Microsoft.VisualStudioCode
winget install MOTU.MSeries
winget install Tailscale.Tailscale
winget install Microsoft.PowerToys
winget install Adobe.CreativeCloud

# Install WSL2
wsl --install --no-distribution

# Pull Starship config
New-Item -ItemType Directory -Path "$HOME\.config" -Force | Out-Null; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chriscorbell/dotfiles/refs/heads/main/.config/starship.toml" -OutFile "$HOME\.config\starship.toml"

# Install Bun
powershell -c "irm bun.sh/install.ps1|iex"

# Install uv + python
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
$env:Path = "$HOME\.local\bin;$env:Path"
uv python install

# Restore classic right-click menu
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
