
Function Save-PImage {


    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [String[]]$Path
    )

    Begin {
        Import-module D:\scripts\Modules\InternetExplorer\InternetExplorer.psm1
    }

    Process {
        Foreach ( $P in $Path ) {

            Write-Verbose "Get shortcut files from path: $P "
            'http://en.wikipedia.org/wiki/Reser_Stadium','http://www.huskermax.com' | Foreach {
                
                Write-Verbose "Processing Page $_"

                $IE = Open-IEWebPage -Url $_ -Visible

                # ----- Depending on what the web page is, only return the images with specific names
                switch -regex ( $_ ) {
                    'wikipedia.org' {
                        Write-Verbose "Wikipedia.org page"
                        $RegexFilter = '\d+[^,\.]+\.jpg'
                    }
                    default {
                        Write-Error "Default Process Missing ----- $_"
                        "Default Process Missing ----- $_" | Out-File -filepath "$Path\LinkErrors.log" -Append
                        $BreakError = $True
                    }
                }
                
                # ----- Continue if Process for web page exists
                if ( -Not $BreakError ) {

                    $Images = $IE | Get-IEWebPageImage | where SRC -Match $RegexFilter

                    # ---- Return a valid path to save the images
                    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
                    $DestinationPath = [Microsoft.VisualBasic.Interaction]::InputBox("Destination Path for the Images:","Destination Path" )
                    While ( ($destinationPath -NotMatch "(?:\\\\[^,\\]+\\)?.[:$].+") -and ($DestinationPath -eq $Null) -and ($DestinationPath -eq "") ) {
                        $DestinationPath = [Microsoft.VisualBasic.Interaction]::InputBox("Destination Path Entered was not Valid.  Please enter a valid Destination Path:","Destination Path" )
                    }

                    # ----- TODO Validate the destination path is in valid form

                    if ( ($DestinationPath -ne $Null) -and ($DestinationPath -ne "") ) { 
                            $Images | Save-IEWebImage -Destination $DestinationPath

                        }
                        Else {
                            Write-Error "Destination is Blank or Empty ----- $_"
                            "Destination is Blank or Empty ----- $_" | Out-File -FilePath "$Path\LinkErrors.log" -Append
                    }
                }

                # ----- Clean up

                Close-IEWebPage -WebPage $IE 

                # ----- TODO if no errors Delete Shortcut
            }
        }
    }

    End {
        Remove-Module InternetExplorer
    }
}


Save-Pimage -Path c:\temp -verbose
