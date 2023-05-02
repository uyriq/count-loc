# Count-Loc: A PowerShell Module to Count Lines of Code in Git Commits

Count-Loc is a PowerShell module that uses the git stat command to count the lines of code (LOC) in git commits. It can help you measure the productivity and quality of your code, as well as track the changes over time. You can use Count-Loc to count the total LOC, the inserted LOC, the deleted LOC, and the average LOC per number of commits in daterange.

## Features

- Count LOC for a given number of days, a specific date range, or a custom period
- Do stat by specific author name or by default option of last commit author
- Display the results in console
- command run under Windows and Linux (tested on Ubuntu 20.04 with bash and PowerShell 7.1.3))
  TODO: Export the results to a CSV file or a HTML report
  TODO: use Count-Loc in github actions to provide artefacts and possible update readme on trigger events

## Installation

To install Count-Loc from the PowerShell Gallery, run the following command:

```powershell

Install-Module -Name count-loc -Repository PSGallery -Scope CurrentUser

```

after install check result of command

```powershell
Get-Command -Module count-loc
```

it should return something like this

```text
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Count-Loc                                          1.0.5      count-loc
```

To update Count-Loc to the latest version, run the following command:

```powershell
Update-Module -Name count-Loc
```

To uninstall Count-Loc, run the following command:

```powershell

remove-Module -Name count-Loc

```

## Usage

To use Count-Loc, you need to have git version 2.16 or higher installed on your system. You also need to be in a git repository folder unless function trow exception error.

To count LOC for the last 5 days, for the first author in the list of authors, run the following command:

```powershell
Count-Loc -NumberDays 5
```

To count LOC for a specific date range, for a specific author, run the following command:

```powershell
Count-Loc -Since 2023-04-20 -Until 2023-04-28 -Author uyriq # the only date format that is supported is yyyy-MM-dd
```

To count LOC for a custom period, using relative dates, for a specific author, run the following command:

```powershell
Count-Loc -Since 5 -Until 1 -Author uyriq
```

This will count LOC from 5 days ago until 1 day ago, for the author uyriq.

To list all possible authors, run the following command:

```powershell
Count-Loc -ListAuthors
```

For more information on function properties, use the `Get-Help` command:

```powershell
Get-Help Count-Loc -Full
Get-Help Count-Loc -Examples
Get-Help Count-Loc -?
```

## Requirements

To use Get-Loc, you need to have git version 2.16 or higher installed on your system. You can download git from https://git-scm.com/downloads.
it is not a req, but also a good idea to have module posh-git installed. this module can install Git for you and also provides a nice prompt in PowerShell.

## LICENSE: MIT

[LICENSE](./LICENSE)

## Author

**Uyriq**
Twitter: [@uniqabble](https://twitter.com/uniqabble)
