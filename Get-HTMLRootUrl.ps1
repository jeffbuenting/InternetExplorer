Function Get-HTMLRootUrl {

<#
    .Synopsis
        returns HTML address root url
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String[]]$Url
    )

    Process {
        Foreach ( $U in $Url ) {
            Write-Verbose "Finding root path for $U"
            
            if ( $U -match '(?''base''http:\/\/.*?\/)' ) { Write-Output ( $Matches['base'].Trimend('/') ) }
        }
    }

}

$Url = 'http://www.nnconnect.com/nikki_sims/merry_xmas_2015.html'

Get-HTMLRootUrl -Url $Url