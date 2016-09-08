
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
                    default {
                        Write-Error "Default Process Missing ----- $_"
                        "Default Process Missing ----- $_" | Out-File -filepath "$Path\LinkErrors.log"
                        break
                    }
                    

                }

                $Images = $IE | Get-IEWebPageImage

                [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
                $DestinationPath = [Microsoft.VisualBasic.Interaction]::InputBox("Destination Path for the Images:","Destination Path" )

                if ( ($DestinationPath -ne $Null) -and ($DestinationPath -ne "") ) { 
                        $Images | Save-IEWebImage -Destination $DestinationPath

                    }
                    Else {
                        Write-Error "$Destination is Blank or Empty ----- $_"
                        "$Destination is Blank or Empty ----- $_" | Out-File -FilePath "$Path\LinkErrors.log"
                }

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
