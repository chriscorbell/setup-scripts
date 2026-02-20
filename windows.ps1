Write-Host "Press any key to open UAC settings, then disable UAC by changing the slider to 'Never notify'" -ForegroundColor Cyan
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null
useraccountcontrolsettings
Write-Host "Confirm UAC is disabled, then press any key to continue" -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null

winget upgrade --all
winget install 7zip.7zip
winget install Gyan.FFmpeg
winget install 9N1F85V9T8BN
winget install Microsoft.Teams
winget install Microsoft.Office
winget install Starship.Starship
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
wsl --install --no-distribution

# Install Bun
powershell -c "irm bun.sh/install.ps1|iex"

# Restore classic right-click menu
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
