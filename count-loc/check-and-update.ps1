# Auto-Update PowerShell
# fromsite: https://www.j3ns.de/powershell/auto-update-powershell-modules/
function CheckAndUpdateModule {
    param (
        [string]$Module = '',
        [bool]$UninstallFirst = $false
    )

    # Read the currently installed version
    $installed = Get-Module -ListAvailable -Name $Module -ErrorAction SilentlyContinue
    # Install if not existing
    if (!$installed) {
        Install-Module -Name $Module  -Scope CurrentUser -Force -AllowClobber -Verbose:$false
        exit
    }

    # There might be multiple versions
    if ($installed -is [array]) {
        $installedversion = $installed[0].version
    }
    else {
        $installedversion = $installed.version
    }
    # Lookup the latest version online
    $online = Find-Module -Name $Module -Repository PSGallery -ErrorAction Stop
    $onlineversion = $online.version
    # Compare the versions
    if ($onlineversion -gt $installedversion) {
        # Uninstall the old version
        if ($UninstallFirst -eq $true) {
            Write-Output "Uninstalling prior Module $Module version $installedversion"
            Uninstall-Module -Name $Module -Force -Verbose:$false
        }
        Write-Output "Installing newer Module $Module version $onlineversion"
        Install-Module -Name $Module -Scope CurrentUser -Force -AllowClobber -Verbose:$false
    }
    else {
        Write-Output "Module $Module version $installedversion loaded"
    }
}