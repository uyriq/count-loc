# Description: Count lines of code
# Author: uyriq
# Version: 1.0.10
# Date: 2023-06-06
Get-ChildItem -Path "$PSScriptRoot\*.ps1" -Exclude *.Tests.ps1 | ForEach-Object { . $_.FullName }
# Auto-Update PowerShell Module count-loc if newer version is available in PSGallery
CheckAndUpdateModule -Module "count-loc" -UninstallFirst $true
# set alias for Measure-Loc to Count-Loc
Set-Alias -Name Count-Loc -Value Measure-Loc
Export-ModuleMember  -Function Measure-Loc -Alias Count-Loc