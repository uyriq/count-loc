function Measure-Loc {
    <#
    .SYNOPSIS
    Using of git stat to count Lines of code total, inserted, deleted and average
    .DESCRIPTION
    Helper Measure-Loc (alias Count-Loc) to count LOC of git commits with git stat command on the fly with varios options      
    .PARAMETER NumberDays
    The number of days to count LOC from
    .PARAMETER Author
    The author of the git commits
    .PARAMETER Since
    The start date in format "YYYY-MM-DD", or number of days ago of the git commits period
    .PARAMETER Until
    The end date in format "YYYY-MM-DD", or number of days ago of the git commits period
    .PARAMETER ListAuthors
    List all possible authors
    .PARAMETER Help 
    Count-Loc is a simple helper to use git stat command on the fly. you can specify date range, or number of days from current date, chose author of commits,
    list all possible authors with -ListAuthors. at least one parameter is required. check parameters with Get-Help Count-Loc -Full or -?
    .PARAMETER Version
    Show version of the module
    .PARAMETER forceGitIsInstalled
    Mock as git is not installed/installed, for testing purposes this parameter is no use for end user
    .EXAMPLE
    PS C:\> Count-Loc -NumberDays 5 
    check LOC for last 5 days, for the first author in the list of authors
    .EXAMPLE 
    PS C:\> Count-Loc -Since 2023-04-20 -Until 2023-04-28 -Author uyriq
    .EXAMPLE 
    PS C:\> Count-Loc -Since 5 -Until 1 -Author uyriq
    since 5 days ago until 1 day ago, for the author uyriq
    .EXAMPLE
    PS C:\> Count-Loc -ListAuthors
    list all possible authors
    .INPUTS
    None. You cannot pipe objects to Count-Loc.ps1.
    .OUTPUTS
    System.Int Total LOC.
    .LINK
    https://github.com/uyriq/count-loc/blob/main/README.md
    .NOTES
    Author: Uyriq
    Requirements: installed git version 2.16.+ is required. the script is wrapper around git stat command
    #>
    
    param (
        [Parameter(mandatory = $false,
            parametersetname = 'DateRange',
            position = 0
        )]
        [int]$NumberDays,
        [Parameter(
            mandatory = $false,
            parametersetname = 'DateRange'
        )]
        [string]$Author = '',
        [Parameter(
            mandatory = $false,
            parametersetname = 'DateRange'
        )]
        [string]$Since,
        [Parameter(
            mandatory = $false,
            parametersetname = 'DateRange'
        )]
        [string]$Until,
        [Parameter(
            mandatory = $false,
            parametersetname = 'DateRange'
        )]
        [switch]$ListAuthors,
        [Parameter(
            mandatory = $false,
            parametersetname = 'DateRange'
        )]
        [Alias('h, -help')]
        [switch]$Help,
        [Parameter(
            mandatory = $false,
            ParameterSetName = '__AllParameterSets'
        )]
        [Alias('v, -version')]
        [switch]$Version,
        [Parameter(
            mandatory = $false,
            parametersetname = 'DateRange'
        )]
        [Alias('g, -forceGitIsInstalled')]
        [switch]$forceGitInstalled = $false
    )

    if ($Help) { 
        Get-Help Measure-Loc -Detailed | more
        return
    }

    if ($Version) { 
        $currentVersion = ( Get-Module -list -Name count-loc).Version
        if ($null -eq $currentVersion) { 
            $currentVersion = (Import-PowerShellDataFile -Path $(Join-Path -Path "$PSScriptRoot" -ChildPath "count-loc.psd1")).ModuleVersion  # module is not installed, import local file 
        }
        # $NormalizedCurrentVersion = "$($currentVersion.Version.Major).$($currentVersion.Version.Minor).$($currentVersion.Version.Build)" 
        $futureVersion = (Find-Module -Name count-loc -Repository PSGallery).Version
        
        if ($futureVersion -gt $currentVersion ) { 
            Write-Output "latest powershellgallery Count-Loc version is $($futureVersion)"
            Write-Output "Local Count-Loc version is $($currentVersion)"
            Write-Output "Please update Count-Loc module with Update-Module -Name Count-Loc -Scope CurrentUser -Force"
            return
        }
        Write-Output "Your Count-Loc version is $($currentVersion) is up to date with powershellgallery"
        return
    }

    if ($PSBoundParameters.Count -eq 0) { 
        Write-Output 'No parameters given, check possible parameters with -? or -help or Get-Help Count-Loc -Full'
        throw "must specify an author or at least one paramter, check help with -? or -help or Get-Help Count-Loc -Full"       
    }

    $isWindowsOS = $env:OS -match 'Windows'
    $isBash = $env:SHELL -contains '/bin/bash'
    # only if git is installed following line will not throw an error
    try {
        $isGitInstalled = (Invoke-Expression "git --version") -match "git"
    }
    catch {
        Write-Error "An error occurred while checking if Git is installed: $_"
        $isGitInstalled = $false
    }
    if ($isGitInstalled -eq $false) { 
        if ($isWindowsOS) { $url = 'https://git-scm.com/download/win' }
        if ($isBash) { $url = 'https://git-scm.com/download/linux' }
        Write-Output "git is not installed, please install git from $url"
        throw "git is not installed, please install git from $url before using Count-Loc"
    }

    if ($NumberDays -eq 0 -and $Since -eq '' -and $Author -ne '') { 
        Write-Output 'defaulting to 7 days ago'
        $NumberDays = 7 
        $Since = "$NumberDays days ago"
    }
    else { 
        if ($Since -eq '') { 
            $Since = "$NumberDays days ago"
        } 
    }
    if ($Until -eq 0 -or $Until -eq '') { 
        $Until = '0 days ago'
    }
    else {
        if ($Since -match "^[\d\.]+$") { 
            $NumberDays = $Since - $Until 
            $Since = "$Since days ago"
            $Until = "$Until days ago"
        }
        if ($Since -match "^\d{4}-\d{2}-\d{2}$" ) { $NumberDays = (New-TimeSpan -Start "$Since" -End "$Until" ).Days }
    }

    # all these works only if git is installed
    if ($isGitInstalled) {
        if ($Author -eq '') { 
            Write-Output 'defaulting to most recent author in the list of commits authors'
            $Author = (git log --format='%an' | Sort-Object -u  |  ForEach-Object { $_.ToString().Split('\n')[0] })[0]
        }

        $Authors = git log --format='%an' | Sort-Object -u  |  ForEach-Object { $_.ToString().Split('\n')[0] }
        if ($ListAuthors) { 
            Write-Output "Possible authors:" $Authors
            throw "must specify an author or at least one paramter, check help with -? or -help or Get-Help Count-Loc -Full"
            return
        }

        Write-Output "Count LOC for  $Author :"
        Write-Output "stat count from $Since up to $Until given $NumberDays"
        $LinesIns = git log --since="$Since" --until="$Until" --date=local --author $Author --oneline --stat | Select-String -Pattern '\d+ file' |  ForEach-Object { $_.ToString().Split(' ')[6] } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        $LinesDel = git log --since="$Since" --until="$Until" --date=local --author $Author --oneline --stat | Select-String -Pattern '\d+ file' |  ForEach-Object { $_.ToString().Split(' ')[4] } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        Write-Output 'Average of LOC per day:' ([Math]::Round((($LinesIns + $LinesDel) / $NumberDays) + 0.00, 2)) 
        Write-Output 'Deleted Lines of code:' ($LinesDel) 
        Write-Output 'Inserted Lines of code:' ($LinesIns) 
        Write-Output 'Total Lines of code:'  
        return ($LinesIns + $LinesDel)    
    }
    Throw "git is not installed, please install git from $url before using Count-Loc"
} 
