 Function Get-WebPageImage {

 	<#
		.SYNOPSIS
			Downloads all image files from the WebPage Object

		.DESCRIPTION
			Analyzes the web page object for images and returns them.

		.PARAMETER WebPage 
            Web Page object returned from Open-IEWebPage.
		
		.Example
			Get-IEWebPageImage -WebPage $IE

        .Example 
            Open-IEWebPage -Url "http://www.powershell.org" | Get-IEWebPageImage

		.Link
			http://powershell.com/cs/blogs/tobias/archive/2010/03/17/downloading-images-from-webpages.aspx
    #>

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [PSCustomObject[]]$WebPage
    )

    Process {
        foreach ( $WP in $WebPage ) {
  
            Write-Verbose "Getting Images from $($WP.Url)..."

            $WP.HTML.Images | Write-Output

        }
    }

}

New-Alias -Name Get-IEWebPageImage -Value Get-WebPageImage