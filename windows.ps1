Write-Host "Press any key to open UAC settings, then disable UAC by changing the slider to 'Never notify'" -ForegroundColor Cyan
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null
useraccountcontrolsettings
Write-Host "Confirm UAC is disabled, then press any key to continue" -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null

winget upgrade --all
winget install Microsoft.PowerShell
winget install 7zip.7zip
winget install Gyan.FFmpeg
winget install 9NQ7512CXL7T
winget install 9N1F85V9T8BN
winget install Microsoft.Teams
winget install Starship.Starship
winget install Git.Git
winget install GitHub.GitHubDesktop
winget install GitHub.cli
winget install JesseDuffield.lazygit
winget install CrystalDewWorld.CrystalDiskInfo
winget install CrystalDewWorld.CrystalDiskMark
winget install Ollama.Ollama
winget install ImputNet.Helium
winget install Mozilla.Firefox
winget install eloston.ungoogled-chromium
winget install Audacity.Audacity
winget install TGRMNSoftware.BulkRenameUtility
winget install REALiX.HWiNFO
winget install ElementLabs.LMStudio
winget install LocalSend.LocalSend
winget install Discord.Discord
winget install Bambulab.Bambustudio
winget install OBSProject.OBSStudio
winget install Obsidian.Obsidian
winget install MPC-BE.MPC-BE
winget install ente-io.auth-desktop
winget install Proton.ProtonVPN
winget install Valve.Steam
winget install Microsoft.VisualStudioCode
winget install AutoHotkey.AutoHotkey
winget install MOTU.MSeries
winget install Tailscale.Tailscale
winget install Microsoft.PowerToys
wsl --install --no-distribution

# Install Latest Nvidia App
Write-Host "Finding latest NVIDIA App installer URL..." -ForegroundColor Cyan
$pageUrl = 'https://www.nvidia.com/en-us/software/nvidia-app/'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$html = (Invoke-WebRequest -Uri $pageUrl -UseBasicParsing).Content
$match = [regex]::Match($html, 'https://us\.download\.nvidia\.com/nvapp/client/[\d\.]+/NVIDIA_app_v[\d\.]+\.exe')
if (-not $match.Success) { throw "Failed to locate NVIDIA App installer on $pageUrl" }
$downloadUrl = $match.Value
Write-Host "Latest NVIDIA App URL: $downloadUrl" -ForegroundColor Gray
$tempFile = Join-Path $env:TEMP (Split-Path $downloadUrl -Leaf)
Write-Host "Downloading to: $tempFile" -ForegroundColor Cyan
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing
Write-Host "Installing NVIDIA App..." -ForegroundColor Cyan
try {
    $proc = Start-Process -FilePath $tempFile -Wait -PassThru
    if ($proc.ExitCode -ne 0) { throw "Installer exited with code $($proc.ExitCode)" }
}
finally {
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
}
Write-Host "NVIDIA App installed successfully." -ForegroundColor Green

# Install Latest FL Studio
Write-Host "Finding latest FL Studio installer URL..." -ForegroundColor Cyan
$redirectUrl = 'https://support.image-line.com/redirect/flstudio_win_installer'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$request = [System.Net.HttpWebRequest]::Create($redirectUrl)
$request.Method = 'HEAD'
$request.AllowAutoRedirect = $true
$request.UserAgent = 'Mozilla/5.0 (Windows NT; PowerShell)'
$response = $request.GetResponse()
$finalUrl = $response.ResponseUri.AbsoluteUri
$response.Close()
Write-Host "Latest FL Studio URL: $finalUrl" -ForegroundColor Gray
$tempFile = Join-Path $env:TEMP (Split-Path $finalUrl -Leaf)
Write-Host "Downloading to: $tempFile" -ForegroundColor Cyan
Invoke-WebRequest -Uri $finalUrl -OutFile $tempFile -UseBasicParsing
Write-Host "Installing FL Studio..." -ForegroundColor Cyan
Start-Process -FilePath $tempFile -Wait
Write-Host "NVIDIA App installed successfully." -ForegroundColor Green
Remove-Item $tempFile -Force

# Next: Adobe, iLok License Manager