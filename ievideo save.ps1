if ( ( $WebVideo = $WP.document.getElementsByTagName('Video') | Select-Object -ExpandProperty CurrentSRC ) -eq $Null ) {

                write-Verbose 'Parsing Web page code for video sources'
                switch -regex ( $IE.Document.body.innerHTML ) {
                    # ----- NNConnect.com
                    """file"": ""(\S+)""" {
                        Write-Verbose "Found: $($Matches[0])"

                        $baseurl = ($IE.LocationUrl | Select-string -Pattern '[^/]*(/(/[^/]*/?)?)?' | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value).trimend( "/")
                        $WebVideo = "$Baseurl$($Matches[1])"
                        break
                    }
                
                   


                    switch -regex ( $WP.RawContent ) {
                



                    # ---- Find WMV links



                    '<a href=\S+mpg' {
                        Write-Verbose "Found: $($Matches[0])"
                        $WebVideo = $IE | Get-IEWebPageLink | where HREF -Match 'mpg' | Select-Object -ExpandProperty HREF
                     }

                    # ----- Xhampster
                    '<a href=\S+mp4' {
                        Write-Verbose "Found: $($Matches[0])"
                        $WebVideo = $IE | Get-IEWebPageLink | where HREF -Match 'mp4' | Select-Object -ExpandProperty HREF
                     }

                    # -----  Tube8
                    # ----- Does not work.  Pulls an url that is different than what is in the HTML code.
                    "videoUrlJS	= '(\S+)'" {
                        Write-Verbose "Found: $($Matches[0])"
                    
                        $WebVideo = $Matches[1]
                        break
                    }

                    Default {
                        # ---- Find WMV links
                        Write-Verbose "Checking for WMV links"
                        if ( ( $WebVideo = $IE | Get-IEWEBPageLink | where HREF -like '*.wmv' | Select-Object -ExpandProperty HREF ) -eq $Null ) {
                        
                            Write-Verbose "Match not found..."
                            $ChildIE = $IE | Get-IEWebPageLink | where HREF -like '*flashvideo*' | Select-Object -ExpandProperty HREF | Get-IEWebPage -Visible
                            $WebVideo = $ChildIE | Get-IEWebVideo -verbose
                        
                            Close-IEWebPage -webpage $ChildIE
                        }
                    }
                }
            }