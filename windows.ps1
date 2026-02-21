# Disable UAC
Write-Host "Press any key to open UAC settings, then disable UAC by changing the slider to 'Never notify'" -ForegroundColor Cyan
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null
useraccountcontrolsettings
Start-Sleep -Milliseconds 2000
Write-Host "Confirm UAC is disabled, then press any key to continue" -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null

# Set execution policy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# Restore classic context menu
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve

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
# winget source update

# Update existing apps
# winget upgrade --all --accept-source-agreements --accept-package-agreements

# Install new apps
# winget install 7zip.7zip --accept-source-agreements --accept-package-agreements
# winget install Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
winget install Microsoft.PowerShell --accept-source-agreements --accept-package-agreements
# winget install 9N1F85V9T8BN --accept-source-agreements --accept-package-agreements
# winget install Microsoft.Teams --accept-source-agreements --accept-package-agreements
# winget install Microsoft.Office --accept-source-agreements --accept-package-agreements
# winget install Starship.Starship --accept-source-agreements --accept-package-agreements
# winget install ajeetdsouza.zoxide --accept-source-agreements --accept-package-agreements
winget install DEVCOM.JetBrainsMonoNerdFont --accept-source-agreements --accept-package-agreements
# winget install CrystalDewWorld.CrystalDiskInfo --accept-source-agreements --accept-package-agreements
# winget install CrystalDewWorld.CrystalDiskMark --accept-source-agreements --accept-package-agreements
# winget install ImputNet.Helium --accept-source-agreements --accept-package-agreements
# winget install Zen-Team.Zen-Browser --accept-source-agreements --accept-package-agreements
# winget install Google.Chrome --accept-source-agreements --accept-package-agreements
# winget install RaspberryPiFoundation.RaspberryPiImager --accept-source-agreements --accept-package-agreements
# winget install Audacity.Audacity --accept-source-agreements --accept-package-agreements
# winget install TGRMNSoftware.BulkRenameUtility --accept-source-agreements --accept-package-agreements
# winget install REALiX.HWiNFO --accept-source-agreements --accept-package-agreements
# winget install LocalSend.LocalSend --accept-source-agreements --accept-package-agreements
# winget install Discord.Discord --accept-source-agreements --accept-package-agreements
# winget install Bambulab.Bambustudio --accept-source-agreements --accept-package-agreements
# winget install OBSProject.OBSStudio --accept-source-agreements --accept-package-agreements
# winget install MPC-BE.MPC-BE --accept-source-agreements --accept-package-agreements
# winget install ente-io.auth-desktop --accept-source-agreements --accept-package-agreements
# winget install Proton.ProtonVPN --accept-source-agreements --accept-package-agreements
# winget install Valve.Steam --accept-source-agreements --accept-package-agreements
# winget install Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements
# winget install MOTU.MSeries --accept-source-agreements --accept-package-agreements
# winget install Tailscale.Tailscale --accept-source-agreements --accept-package-agreements
# winget install Microsoft.PowerToys --accept-source-agreements --accept-package-agreements
# winget install Adobe.CreativeCloud --accept-source-agreements --accept-package-agreements
# winget remove Microsoft.OneDrive
# winget remove Microsoft.CommandPalette

# Install NVIDIA App (fallback since winget package may be unavailable)
try {
    $nvidiaLandingUrl = "https://www.nvidia.com/en-us/software/nvidia-app/"
    $nvidiaPage = Invoke-WebRequest -Uri $nvidiaLandingUrl -UseBasicParsing
    $nvidiaAppUrl = ($nvidiaPage.Content | Select-String -Pattern 'https://[^"''\s]+NVIDIA_app[^"''\s]+\.exe' -AllMatches).Matches.Value |
        Select-Object -First 1

    if (-not $nvidiaAppUrl) {
        Write-Warning "Could not detect a direct NVIDIA App installer URL automatically. Open $nvidiaLandingUrl and install manually."
    } else {
        $nvidiaInstallerPath = Join-Path $env:TEMP "NVIDIA_app_setup.exe"
        Write-Host "Downloading NVIDIA App installer..." -ForegroundColor Cyan
        $downloadMethod = $null
        $downloadTimer = [System.Diagnostics.Stopwatch]::StartNew()

        if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
            $downloadMethod = "curl.exe"
            & curl.exe -L --fail --retry 3 --retry-delay 2 --output $nvidiaInstallerPath $nvidiaAppUrl
            if ($LASTEXITCODE -ne 0) {
                throw "curl.exe download failed with exit code $LASTEXITCODE"
            }
        } elseif (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
            $downloadMethod = "BITS"
            Start-BitsTransfer -Source $nvidiaAppUrl -Destination $nvidiaInstallerPath -ErrorAction Stop
        } else {
            $downloadMethod = "Invoke-WebRequest"
            $oldProgressPreference = $ProgressPreference
            $ProgressPreference = 'SilentlyContinue'
            try {
                Invoke-WebRequest -Uri $nvidiaAppUrl -OutFile $nvidiaInstallerPath -UseBasicParsing
            } finally {
                $ProgressPreference = $oldProgressPreference
            }
        }

        $downloadTimer.Stop()
        if (Test-Path $nvidiaInstallerPath) {
            $downloadedSizeMB = [Math]::Round(((Get-Item $nvidiaInstallerPath).Length / 1MB), 2)
            $downloadSeconds = [Math]::Max($downloadTimer.Elapsed.TotalSeconds, 0.01)
            $downloadSpeedMBs = [Math]::Round(($downloadedSizeMB / $downloadSeconds), 2)
            Write-Host "NVIDIA installer download complete via $downloadMethod ($downloadedSizeMB MB @ $downloadSpeedMBs MB/s)." -ForegroundColor Green
        }

        Write-Host "Installing NVIDIA App..." -ForegroundColor Cyan
        Start-Process -FilePath $nvidiaInstallerPath -ArgumentList '/S' -Wait
    }
} catch {
    Write-Warning "NVIDIA App installation failed: $($_.Exception.Message)"
}

# Install WSL2
wsl --install --no-distribution

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
