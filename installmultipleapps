# 1. Automatically request Administrator privileges if not already running as Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsRoleId]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. Get the current script directory
$FolderDir = $PSScriptRoot

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Starting Interactive Installer (.exe & .msi)" -ForegroundColor Cyan
Write-Host " Folder: $FolderDir" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 3. Scan for both .exe and .msi files (FIXED: Get-ChildItem path matching)
$AllInstallerFiles = Get-ChildItem -Path "$FolderDir\*" -Include "*.exe", "*.msi" | Where-Object { $_.Name -notmatch "uninstall" }

if (-not $AllInstallerFiles -or $AllInstallerFiles.Count -eq 0) {
    Write-Host "[X] No .exe or .msi files found in this folder!" -ForegroundColor Red
    pause
    exit
}

# 4. Display GUI window to select apps
Write-Host "Please select the application(s) you wish to install..." -ForegroundColor Yellow

$SelectedApps = $AllInstallerFiles | Select-Object Name, Extension, Length, LastWriteTime | 
    Out-GridView -Title "Select Apps to Install (Hold CTRL for multiple)" -PassThru

if (-not $SelectedApps) {
    Write-Host "[!] No applications selected or operation cancelled." -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit
}

Write-Host ""
Write-Host "Total applications selected: $($SelectedApps.Count)" -ForegroundColor Green
Write-Host ""

# 5. Loop through and install based on file type (.exe vs .msi)
foreach ($appSelection in $SelectedApps) {
    $appPath = Join-Path -Path $FolderDir -ChildPath $appSelection.Name
    $extension = $appSelection.Extension.ToLower()

    Write-Host "--------------------------------------------------" -ForegroundColor Yellow
    Write-Host "Installing: $($appSelection.Name)" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------" -ForegroundColor Yellow

    if ($extension -eq ".msi") {
        # Silent install command for .msi files using msiexec
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$appPath`" /qn /norestart" -Wait
    } 
    else {
        # Silent install command for .exe files
        Start-Process -FilePath $appPath -ArgumentList "/S", "/verysilent", "/suppressmsgboxes", "/norestart" -Wait
    }

    Write-Host "[✓] Finished: $($appSelection.Name)" -ForegroundColor Green
    Write-Host ""
    
    Start-Sleep -Seconds 2
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " All selected applications have been successfully installed!" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Start-Sleep -Seconds 3
