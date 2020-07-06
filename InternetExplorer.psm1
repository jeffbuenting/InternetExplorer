#------------------------------------------------------------------------------
# Module InernetExplorer
#
#------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------
# ----- Dot source the functions in the Functions folder of this module
# ----- Ignore any file that begins with @, this is a place holder of work in progress.


Get-ChildItem -path $PSScriptRoot\Functions\*.ps1 | where Name -notlike '@*' | Foreach { 
    Write-Verbose "Dot Sourcing $_.FullName"

    . $_.FullName 
}



#------------------------------------------------------------------------------







#------------------------------------------------------------------------------

Function Close-IEWebPage {

    [CmdLetBinding()]
	Param ( 
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [PSCustomObject[]]$WebPage
    )

    Begin {
        # ----- Set Debug to continue without prompting: http://learn-powershell.net/2014/06/01/prevent-write-debug-from-bugging-you/
        If ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }
    }

    Process {
        Foreach ( $WP in $WebPage ) {
            Write-Verbose "Closing $($WP.Url)"
            Write-Debug ($WP.IE | Out-String )

            $WP.IE.Quit()
        }
    }
}

#------------------------------------------------------------------------------

function Resolve-ShortcutFile {
     
<#
    .Description
        Retrieves the web page address (URL) from a shortcut.
    .Parameter FileName
        Full Path to the shortcut
    .Parameter FilterString
        String to filter.  If the wep page address is 'Like' this string then it will be returned.  Otherwise it will be skipped.
    .LINK
        http://blogs.msdn.com/b/powershell/archive/2008/12/24/resolve-shortcutfile.aspx
#>          
           
    [CmdLetBinding()]
    param(
        [Parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0)]
        [Alias("FullName")]
        [string]$fileName,

        [String]$LikeString = ''
    )
    
    process {
        
        Write-Verbose "Processing $_"
        if ( $LikeString -ne '' ) {
                Write-Verbose "LikeString = $LikeString - something"
                if ($fileName -like "*.url") {
                    Write-Verbose "Filtering Urls"
                    $ShortCut = Get-Content $fileName | Where-Object { $_ -like "url=*" -and $_ -like "*$LikeString*" } 
                    if ( $ShortCut -ne $Null ) {
                        Write-Output ( New-Object -Type PSObject -Property @{'FileName'= $FileName; 'Url' = $ShortCut.Substring($ShortCut.IndexOf("=") + 1 ) } )
                    }
                }
            }
            Else {
                Write-Verbose "LikeString = Empty"
                if ($fileName -like "*.url") {
                    Write-Verbose "Returning all Urls"
                    $ShortCut = Get-Content $fileName | Where-Object { $_ -like "url=*" } 
                    Write-Output ( New-Object -Type PSObject -Property @{'FileName'= $FileName; 'Url' = $ShortCut.Substring($ShortCut.IndexOf("=") + 1 ) } )

                }  
       }          
    
    }

}  

#------------------------------------------------------------------------------

Function Get-IEWebPageLink {

 	<#
		.SYNOPSIS
			Downloads all Links from the WebPage Object

		.DESCRIPTION
			Analyzes the web page object for Links and returns them.

		.PARAMETER WebPage 
            Web Page object returned from Open-IEWebPage.
		
		.Example
			Get-IEWebPageImage -WebPage $IE

        .Example 
            Open-IEWebPage -Url "http://www.powershell.org" | Get-IEWebPageLink

    #>

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [PSCustomObject[]]$WebPage
    )
    
    Begin {
        Write-Verbose "Get-IEWebPageLink"
        if ( $VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue ) {
            Write-Verbose "WebPage Object:"
            $WebPage
        }
    }

    Process {
        foreach ( $WP in $WebPage ) {
            #$WP
            Write-Verbose "Getting Links from $($WP.Url)..."



            $WP.HTML.Links | Write-Output

        }
    }

}

#------------------------------------------------------------------------------
# IE Video
#------------------------------------------------------------------------------

Function Get-IEWebVideo {

 	<#
		.SYNOPSIS
			Downloads all Videos from the WebPage Object

		.DESCRIPTION
			Analyzes the web page object for Videoss and returns them.

		.PARAMETER WebPage 
            Web Page object returned from Open-IEWebPage.
		
		.Example
			Get-IEWebPageImage -WebPage $IE

        .Example 
            Open-IEWebPage -Url "http://www.powershell.org" | Get-IEWebVideo

    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$True )]
        [PSCustomObject[]]$WebPage
    )

    Begin {
        Write-Verbose "Getting Videos from Webpage"
        $WebVideo = @()

        $Patterns = 'file: "(.*\.flv.*)"',
            'file:"(.*\.flv)"',
            "video_url: '(.*\.f4v)",
            'file:\s?"(\S+mp4[^"]*)',
            "file:\s?'(\S+\.mp4)'(?:,label: ""HD"")?",
            """file"": ""(\S+)""",
            "clip: {\s+url: '(\S+\.mp4)'",
            "video_url: '(\S+.mp4)",
            'Url: "(\S+.mp4)',
            "file=(\S+\.mp4)",
            '\[flv\]([\S]+)\[\/flv\]',
            "url: \S+\('([a-z,A-Z,:,\/,\.,\d]+.mp4)",
            "html5player\.setVideoUrlHigh\('(.*)'\);"

    }

    Process {
        foreach ( $WP in $WebPage ) {
            Write-Verbose "Getting Videos from $($WP.Url)..."

            $BreakError = $False
            $WebVideo = $Null

            Write-Verbose 'Get HTML5 Video elements'
            
            write-Verbose 'Parsing Web page code for video sources'
           
            #Write-Debug "HTML"
            #Write-Debug ($WP.HTML.allelements | Out-String )
            #$WP.HTML.allelements
            Write-Verbose "Checking Tags"
            Write-Verbose "               Source"
            
           $WP.HTML.allelements | where tagname -eq source | Write-Verbose
           

            $File = $WP.HTML.allelements | where tagname -eq source | where { ($_.src -like '*.m4v') -or ( $_.src -like '*.webm' ) -or ( $_.src -like '*.mp4') } | Select-object -ExpandProperty src
            $File += $wp.html.links | where href -like "*.wmv" | Select-Object -ExpandProperty href
            
            # ----- Convert File to object
            $WebVideo = @()
            foreach ( $F in $File ) {
                $Vid = New-Object -TypeName PSObject -Property (@{
                    'Pattern' = 'SourceTag'
                    'Matches' = $F
                })
                $WebVideo += $Vid
            }

            $Videos = @()
            Write-Verbose "Checking if WebVideo contains HTTP"
            foreach ( $V in $WebVideo ) {
                Write-Verbose "WebVideo = $($V.Matches)"
                
                if ( $V.Matches -notcontains 'http://' ) {
                    Write-verbose "No Http add base url"

                    # ----- Remove index.htm if there
                    $BaseUrl = $WP.Url -replace 'index.html',''

                    # ----- Remove query after ?
                    if ( $BaseUrl | Select-String -Pattern '\?' -Quiet ) { 
                        $BaseUrl = ($BaseUrl.Split( '?' ))[0]
                    }

                    Write-Verbose "BaseUrl = $BaseUrl"
                    $V.Matches = "$BaseUrl$($V.Matches)"
                }
                $Videos += $V
            }
            $WebVideo = $Videos

                
            Write-Verbose "Checking HTML Code"


            $WebVideo += ($WP.HTML.RawContent).split( "`n" ) | Select-String -Pattern $Patterns -AllMatches | Select-Object pattern, @{N='matches';e={ $_ | foreach { $_.matches.groups.groups[1].value } }}

            Write-Verbose "Matched Count = $($WebVideo.Count)"

        
            foreach ($M in $WebVideo ) {
                Write-Verbose "Video Url:"
                Write-Verbose "Video = $($M.Matches)"
                Write-Verbose "Pattern = $($M.Pattern)"
                
                Write-Output $M.Matches
            }
        }
    }

    End {
        Write-Verbose "Ending Get-WebVideo --------------------------------------------"
    }
}

#------------------------------------------------------------------------------


Function Get-HTMLBaseUrl {

<#
    .Synopsis
        Returns the Base path of an HTML Url address.

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
            Write-Verbose "Finding Base path for $U"

            # ----- Removing query (Everything after the ?)
            if ( $U.Contains('?') ) {
                Write-Verbose "Removing query (?)"
                $Root = ($U.split( '?' ))[0]

                # ----- Removing page name
                Write-Verbose "Removing page file name from $Root"
                Write-Output $Root.substring( 0,$Root.lastindexof( '/' ) )
                break
            }

            # ----- remove page from URL
            if (( $U.Contains('.html')) -or ($U.Contains('.php')) ) {
                
                Write-Verbose "Removing HTML/PHP page file name from $U"
                write-verbose "new Base: $($U.substring( 0,$U.lastindexof( '/' ) ))"
                Write-Output ($U.substring( 0,$U.lastindexof( '/' )+1 ))
                break
            }

            Write-Verbose "Returning input unprocessed as it is already the root"
            Write-Output $U
        }
    }
}

#------------------------------------------------------------------------------

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

#------------------------------------------------------------------------------

Function Get-IEResponse {
    
<#
    .Link
        http://stackoverflow.com/questions/1473358/how-to-obtain-numeric-http-status-codes-in-powershell
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String]$Url
    )

    Process {
        Write-Verbose "Getting website Respose for: $Url"
        $Request = [System.Net.HttpWebRequest]::Create($Url)
        try {
                $Response = $Request.GetResponse() 
            }
            Catch {
                Write-Verbose "Error getting Response"
                $Response = $Error[0].Exception.InnerException.Response
        }

       # if ( -Not $Resonse ) { $Response = $Error[0].Exception.InnerException.Response }

        Write-Verbose "Status = $([Int]$Response.StatusCode)"
        
        $Response | Add-Member -MemberType NoteProperty -Name 'Status' -Value ([Int]$Response.StatusCode)
        Write-Output $Response
    }
}

#------------------------------------------------------------------------------

Function Test-IEWebPath {

<#
    .Synopsis
        Checks if a web path exists

    .Description
        Used to check if a web path exists.  For example.  Is the address to a JPG valid.

    .Parameter Url
        Address to the Web Path to test

    .Example
        test if the following JPG exists at the specified webpage

        Test-IEWebPath -Url http://www.contoso.com/award.jpg

    .Link
        http://stackoverflow.com/questions/20259251/powershell-script-to-check-the-status-of-a-url
#>
    
    [CmdletBinding()]
    Param (
        [String]$Url
    )


    # First we create the request.
    $HTTP_Request = [System.Net.WebRequest]::Create($Url)

    # We then get a response from the site.
    $HTTP_Response = $HTTP_Request.GetResponse()

    # We then get the HTTP code as an integer.
    $HTTP_Status = [int]$HTTP_Response.StatusCode

    If ($HTTP_Status -eq 200) { 
        Write-Output $True 
    }
    Else {
        Write-Output $Fals
    }

    # Finally, we clean up the http request by closing it.
    $HTTP_Response.Close()
}

Function Test-IEWebPath {

<#
    .Synopsis
        Checks if a web path exists

    .Description
        Used to check if a web path exists.  For example.  Is the address to a JPG valid.

    .Parameter Url
        Address to the Web Path to test

    .Example
        test if the following JPG exists at the specified webpage

        Test-IEWebPath -Url http://www.contoso.com/award.jpg

    .Link
        http://stackoverflow.com/questions/20259251/powershell-script-to-check-the-status-of-a-url
#>
    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]
        [String]$Url
    )

    Write-Verbose "Test-IEWebPath : Checking for existence of $Url"

    # First we create the request.
    $HTTP_Request = [System.Net.WebRequest]::Create($Url)
    Try {
            # We then get a response from the site.
            $HTTP_Response = $HTTP_Request.GetResponse()

            # We then get the HTTP code as an integer.
            $HTTP_Status = [int]$HTTP_Response.StatusCode

            If ($HTTP_Status -eq 200) { 
                Write-Output $True 
            }
            Else {
                Write-Output $False
            }

            # Finally, we clean up the http request by closing it.
            $HTTP_Response.Close()
        }
        Catch {
            Write-Output $False
    }
}






#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

Set-Alias -Value Open-IEWebPage -Name Get-IEWebPage
Set-Alias -Value Save-IEWebImage -Name Save-IEWebVideo

#Export-ModuleMember -Function Open-IEWebPage,Close-IEWebPage,Get-IEWebPageImage,Save-IEWebImage,Resolve-ShortcutFile,Get-IEWebPageLink,Get-IEWebVideo,Get-HTMLRootPath -Alias Save-IEWebVideo,Get-IEWebPage