$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-WebAppPool" {
    It "Output Application Pool Object" {
        Get-WebAppPool | Should BeofType PSCustomObject
    }
}
