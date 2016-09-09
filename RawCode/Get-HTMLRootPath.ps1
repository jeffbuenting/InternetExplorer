Function Get-HTMLRootPath {

<#
    .Synopsis
        Returns the root path of an HTML Url address.

    .Description
        Using this you can build a complete path from a relitive path found in image and href items.

#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String[]]$Url
    )

    Process {
        Foreach ( $U in $Url ) {
            Write-Verbose "Finding root path for $U"

            # ----- Removing query (Everything after the ?)
            if ( $U.Contains('?') ) {
                Write-Verbose "Removing query (?)"
                $Root = ($U.split( '?' ))[0]

                # ----- Removing page name
                Write-Verbose "Removing page file name from $Root"
                Write-Output $Root.substring( 0,$Root.lastindexof( '/' )+1 )
            }
            Write-Verbose "Returning input unprocess as it is already the root"
            Write-Output $U
        }
    }
}

| Get-HTMLRootPath -Verbose