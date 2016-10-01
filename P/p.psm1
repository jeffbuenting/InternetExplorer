Function Get-PImages {

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [PSCustomObject[]]$WebPage,

        [int]$RecurseLevel = 0,

        [int]$MaxRecurseLevel = 1
    )

    Begin {
        # ----- List of words to ignore if they are part of an image link
        $ExcludedWords = '468x60','anna','atk',
                    'backtohome','backtohome','banner','bella','big.jpg','box_title_main_menu',
                    '/cm/',
                    'friends','front','frontpage',
                    'gallery-','girls/',
                    'header','header','hor_',
                    'imgs/','/img',
                    'kris',
                    'littlepics','lily.jpg','logo',
                    'newupdates','nov',
                    'oct',
                    'paysite.jpg',
                    'sascha','search','separator','small','stmac.jpg',
                    't.jpg','Template','tgp','thumb','tk_','tn.jpg','tn2','tn_','/th'
                    'webcam'
    }
   

    process {
        Write-Verbose "Get-PImage : Recurse Level : $RecurseLevel"
        Write-Verbose "Adding recurse level"
        $RecurseLevel ++

        ForEach ( $WP in $WebPage ) {

            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"

            Write-Verbose "Get-PImages : Getting Images from $($WP.URL)..."

            $Pics = @()

            #-------------------------------------------------------------------------------
            # ----- Images on the page.
            Write-verbose "Get-PImages : ---------------------------- Checking for images on page."

            $WP.HTML.images | where src -match '\d*\.jpg' | foreach {
                $SRC = $_.SRC

                Write-Verbose "Get-PImages : Examining: $($_.src)"

                # ----- Check if any excluded word is in the string.
                if ( $_.src | Select-String -Pattern $ExcludedWords -NotMatch ) {                                      

                        # ----- Match was 
                        Write-Verbose "Get-PImage : ----- $SRC -- Does the image start with HTTP?" 
                        if ( ( $_.SRC -Match 'http:\/\/.*\/\d*\.jpg' ) -or ($_.SRC -Match 'http:\/\/.*\d*\.jpg' ) ) { 
                                Write-Verbose "Get-PImages : returning full JPG Url $($_.SRC)"
                      
                                $Pics += $_.SRC
                                Write-Verbose "Get-PImages : -----Found: $($_.SRC)"
                                Write-Output $_.SRC 
                        }

                        Write-Verbose "Get-PImage : ----- $($_.src) -- No HTTP"                  
                        If ( ($_.SRC -notmatch 'http:\/\/.*' ) ) {
                            
                                    $PotentialIMG = $_.SRC
                            
                                    # ----- Check if the link contains /tn_.  if so remove and process image
                                    if ( $PotentialIMG.Contains( "\/tn_") ) {
                                        $PotentialIMG = $PotentialIMG.Replace( '/tn_','/')
                                    }

                                    Write-Verbose "Get-PImages : JPG Url is relitive path.  Need base/root."
                                    $Root = Get-HTMLBaseUrl -Url $WP.Url -Verbose
                                    if ( -Not $Root ) { $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose }

                                    # ----- Check to see if valid URL.  Should not contain: //
                                    if ( ("$Root$_" | select-string -Pattern '\/\/' -allmatches).matches.count -gt 1 )  {
                                        Write-Verbose "Get-PImages : Illegal character, Getting Root"
                                        $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose
                                    }

                           

                                    # ----- Checking if image is a valid path
                                   # $URL = "$Root$($_.SRC)"
                                  #  Write-Verbose "+++++++++++$Root$($_.SRC)"
                                    if ( Test-IEWebPath -Url "$Root$PotentialIMG" -ErrorAction SilentlyContinue ) {
                                            $Pics += "$Root$PotentialIMG"

                                            Write-Verbose "-----Found: $Root$PotentialIMG"
                                            Write-Output "$Root$PotentialIMG"
                                        }
                                        else {
                                            Write-Verbose "Get-PImage : Root/SRC is not valid.  Checking Root/JPG"
                                            $JPG = $PotentialIMG | Select-String -Pattern '([^\/]+.jpg)' | foreach { $_.Matches[0].value }
                                            if ( Test-IEWebPath -Url $Root$JPG ) {
                                                Write-Verbose "-----Found: $Root$JPG"
                                                Write-Output $Root$JPG
                                            }
                                    }
                                }
                                Else {
                                    Write-Verbose "Get-PImages :  Image not found $($_.SRC)"
                                    $_.SRC
                                    write-Verbose "fluffernuter"

                        
                            
                        }
                    }
                    else {
                        Write-Verbose "$($_.SRC) matches:"
                        Write-Verbose "$($_.src | Select-String -Pattern $ExcludedWords -NotMatch | Out-String ) "
                }

            }

           
            if ( $Pics ) { Break }
            
            #-------------------------------------------------------------------------------
            # ----- Check for full URL to Images ( jpgs )
            Write-Verbose "Get-PImages : ---------------------------- Checking for JPG with full URL"
            $WP.HTML.links | where { ( $_.href -Match 'http:\/\/.*\.jpg' ) -and ( -Not $_.href.contains('?') ) } | Select-Object -ExpandProperty HREF | Where { Test-IEWebPath -Url $_ } | Foreach {
                Write-Verbose "***** Found : $_"
                Write-Output $_
            }
            #if ( $FullJPGUrl ) {
            #    Write-Verbose "***** Found: $FullJPGUrl"
            #    Write-Output $FullJPGUrl
            #}

         #   if ( $WP.HTML.links | where { ( $_.href -Match 'http:\/\/.*\.jpg' ) -and ( -Not $_.href.contains('?') ) } ) { break }
            
            #-------------------------------------------------------------------------------
            # ----- Check to see if there are links to images ( jpgs ) - Relative Links (not full URL)
            Write-Verbose "Get-PImages : ---------------------------- Checking for Links to JPGs"
            $Root = Get-HTMLBaseUrl -Url $WP.Url -Verbose
            if ( -Not $Root ) { $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose }

            Write-Verbose "Website Root Path = $Root"
            $WP.HTML.links | where href -like *.jpg | Select-Object -ExpandProperty href | Foreach {
                Write-Verbose "Image Found: $Root$_"
                
                # ----- Check to see if valid URL.  Should not contain: //
                if ( (("$Root$_" | select-string -Pattern '\/\/' -allmatches).matches.count -gt 1) -or ( ("$Root$_").contains('#') ) ) {
                    Write-Verbose "Illegal character, Getting Root"
                    $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose
                }
                if (( $_[0] -ne '/' ) -and ( $Root[$Root.length - 1] -ne '/' ) ) { $HREF = "/$_" } else { $HREF = $_ }

                # ----- Check if the image exists
                Write-Verbose "Get-PImage : Checking if image path exists and correct"
                if ( Test-IEWebPath -Url $Root$HREF -ErrorAction SilentlyContinue ) {
                        Write-Verbose "-----Found: $Root$HREF"
                        Write-Output $Root$HREF
                    }
                    else {
                        Write-Verbose "Get-PImage : Root/HREF is not valid.  Checking Root/JPG"
                        $JPG = $HREF | Select-String -Pattern '([^\/]+.jpg)' | foreach { $_.Matches[0].value }
                        if ( Test-IEWebPath -Url $Root$JPG -ErrorAction SilentlyContinue ) {
                            Write-Verbose "-----Found: $Root$JPG"
                            Write-Output $Root$JPG
                        }
                }
            }
            
            if ( $WP.HTML.links | where href -like *.jpg ) { break }

            #-------------------------------------------------------------------------------
            # ----- Check for links to image page ( ddd.htm )
            Write-Verbose "Get-PImages : ---------------------------- Checking for html links"

            # ----- Do not process if we have already followed one link ( stop if the URL is PHP )
            if ( $WP.Url -notmatch "\d+\.php" ) {
                $Root = Get-HTMLBaseUrl -Url $WP.Url -Verbose
                if ( -Not $Root ) { $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose }

                $HTMLLinks = $WP.HTML.Links | where { ($_.href -like "*.html") -or ($_.HREF -match "\d+\.php") } | Select-Object -ExpandProperty href 
                
                # ----- Check if Full Link (http) rood is the same
                $L = @()
                Foreach ( $H in $HTMLLinks ) {
                    write-Verbose "Checking $H"
                    if ( $H -match 'http:\/\/' ) {
                            Write-Verbose "Full HTTP Url"
                            $RootForLink = Get-HTMLBaseUrl -Url $H -Verbose
                            if ( $Root -eq $RootForLink ) { 
                                    Write-Verbose "$Root = $RootForLink"
                                    $L += $H
                                }
                                Else {
                                    Write-Verbose "$Root != $RootForLink"
                            }
                        }
                        else {
                            Write-Verbose "Not full HTTP Url"
                            $L += $H
                    }

                }

                Write-Verbose `n$L

                $L | foreach {
                    Write-Verbose "`n"
                    Write-Verbose "Can I follow : $_"
                
                    $HREF = $_
                    $Root = $Null

                    if ( -not ( $_ -match 'http:\/\/' ) ) { 
                            $Root = Get-HTMLBaseUrl -Url $WP.Url -Verbose
                            if ( -Not $Root ) { $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose }
                            # ----- Test if webpage exists
                            if ( Test-IEWebPath -url $Root$HREF ) {
                                write-Verbose "Get-PImage : Malformed web page.  checking for //"
                                # ---- checking if // is in the middle of string
                                if ( $Root[$Root.Lenght()-1] -eq '/' -and $HREF[0] -eq '/' ) {
                                    Write-Verbose "Get-PImage : Removing //"
                                    $HREF = $HREF.substring[1] 
                                }

                                if ( -Not (Test=IEWebPath -Url $Root$HREF) ) {
                                    Throw "Get-PImage : WebPage does not exist $Root$HREF"
                                } 
                            }



                            Write-Verbose "Get-PImages : ---------------------------- Following Link: $Root$HREF"
                            Try {
                                    # ----- Check if we are recursing and how deep we have gone.
                                    if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                                        Write-Output ( Get-IEWebPage -Url $Root$HREF -Visible | Get-PImages -RecurseLevel $RecurseLevel -Verbose )
                                    }
                                }
                                Catch {
                                    # ----- If error following web link.  Try getting web root and following that
                                    $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose 
                                    Write-Verbose "Error -- Will Try : $Root$HREF "
                                    # ----- Check if we are recursing and how deep we have gone.
                                    if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                                        Write-Output ( Get-IEWebPage -Url $Root$HREF -Visible | Get-PImages -RecurseLevel $RecurseLevel -Verbose )
                                    }

                            }
                        }
                        else {

                            Write-Verbose "Get-PImages : -------------------- Following Link: $HREF"


                            # Write-Output (Get-IEWebPage -url $HREF -Visible | Get-Pics -Verbose)
                            # ----- Check if we are recursing and how deep we have gone.
                            if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                                Write-Output (Get-IEWebPage -url $HREF -Visible | Get-PImages -RecurseLevel $RecurseLevel -Verbose)
                            }
                    }
                }
            }
  
            if ( $WP.HTML.Links | where href -like  *.html ) { Break }

            #-------------------------------------------------------------------------------
            # ----- Checking for links where the src is a jpg thumbnail ( link does not end in html )
            Write-Verbose "checking for links where the src is a tn.jpg"
            $WP.HTML.Links | where { ( $_.innerHTML -match 'src=.*tn\.jpg' ) } | Foreach {
                if ( $_.HREF -match 'http:\/\/' ) {
                    $HREF = $_.href
                    Write-Verbose "Following Link: $HREF"
                    #Get-IEWebPage -Url $HREF -visible

                    Write-Verbose "RecurseLevel = $RecurseLevel"
                    Write-Verbose "MaxRecurseLevel = $MaxRecurseLevel"
                    # ----- Check if we are recursing and how deep we have gone.
                    if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                        $Pics = Get-IEWebPage -url $HREF -Visible | Get-PImages -RecurseLevel $RecurseLevel -Verbose
                    }

                    Write-Output $Pics
                }
                
            }

            if ( $Pics ) { Break }
           
        }
    }



}

#--------------------------------------------------------------------------------------

