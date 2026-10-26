# 1. Automatically request Administrator privileges if not already running as Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsRoleId]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Loading installed applications from system..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 2. Fetch installed apps list from Windows Registry (32-bit & 64-bit)
$RegPaths = @(
    "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$InstalledApps = Get-ItemProperty -Path $RegPaths | 
    Where-Object { $_.DisplayName -and $_.UninstallString } | 
    Select-Object DisplayName, UninstallString, Publisher | 
    Sort-Object DisplayName -Unique

if (-not $InstalledApps) {
    Write-Host "[X] No applications found!" -ForegroundColor Red
    pause
    exit
}

# 3. Display GUI window for app selection
Write-Host "Please select the application(s) you wish to uninstall from the pop-up window..." -ForegroundColor Yellow

$SelectedApps = $InstalledApps | Out-GridView -Title "Select Apps to Uninstall (Hold CTRL for multiple)" -PassThru

if (-not $SelectedApps) {
    Write-Host "[!] No applications selected or operation cancelled." -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit
}

Write-Host ""
Write-Host "Total applications selected for uninstallation: $($SelectedApps.Count)" -ForegroundColor Green
Write-Host ""

# 4. Loop through and uninstall each selected app
foreach ($app in $SelectedApps) {
    Write-Host "--------------------------------------------------" -ForegroundColor Yellow
    Write-Host "Uninstalling: $($app.DisplayName)" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------" -ForegroundColor Yellow

    $uninstallString = $app.UninstallString

    # Determine silent uninstallation flags based on installer type
    if ($uninstallString -match "MsiExec.exe") {
        # For MSI packages, replace /I with /X and add silent flags
        $uninstallString = $uninstallString -replace "/I", "/X"
        if ($uninstallString -notmatch "/qn") { $uninstallString += " /qn /norestart" }
        
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString" -Wait
    } 
    else {
        # For standard EXE uninstallers, append silent switches if not already present
        if ($uninstallString -notmatch "/S" -and $uninstallString -notmatch "/silent" -and $uninstallString -notmatch "/verysilent") {
            $uninstallString += " /S"
        }
        
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$uninstallString`"" -Wait
    }

    Write-Host "[✓] Finished processing: $($app.DisplayName)" -ForegroundColor Green
    Write-Host ""
    
    Start-Sleep -Seconds 2
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " All selected applications have been processed!" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Start-Sleep -Seconds 4
