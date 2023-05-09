Get-ChildItem -Path "$PSScriptRoot\*.ps1" | ForEach-Object { . $_.FullName }
# want to set alias for Measure-Loc to Count-Loc
Set-Alias -Name Count-Loc -Value Measure-Loc
Export-ModuleMember  -Function Measure-Loc -Alias Count-Loc