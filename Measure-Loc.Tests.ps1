
Describe 'Measue-Loc' {

    BeforeAll {
        . $(Join-Path -Path "$PSScriptRoot" -ChildPath "count_loc.ps1")
        
    }

    Context 'no parameters' {
        It 'Given no parameters, it fails with trow error' {
            { Measure-Loc } | Should -Throw -ExpectedMessage 'must specify an author or at least one paramter, check help with -? or -help or Get-Help Count-Loc -Full'
        }
    }
    Context 'version' {
        It 'Given -version, it returns version' {
            Measure-Loc -Version | Should -Be 'Count-Loc version is 1.0.9'
        }
    }
}