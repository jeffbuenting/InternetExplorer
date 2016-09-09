Import-module c:\scripts\Modules\InternetExplorer\InternetExplorer.psm1 -Force
Import-Module C:\scripts\FilesandFolders\filesandfolders.psm1 -Force
Import-Module c:\scripts\modules\popup\popup.psm1
Import-Module C:\Scripts\Modules\Shortcut\Shortcut.psm1 -force

    # ---- Return a valid path to save the images
Import-Module c:\scripts\modules\pp.psm1 -Force

$Path = 'P:\Links\2010\2010 FEB'
get-childitem -path $Path -File -ErrorAction Stop | Select -first 1 | foreach {
    #$_ | FL *
    Write-Host "$($_.Name)" -ForegroundColor Green

    
    $IE = $_ |  Resolve-ShortcutFile | Select-Object -ExpandProperty Url | Get-IEWebPage -Visible

    #$IE

    $DestinationPath = Get-FileorFolderPath -InitialDirectory 'p:\'

    if ( ($DestinationPath -ne $Null) -and ($DestinationPath -ne "") ) { 
            $Images = $Null

            $Images = $IE | Get-PornImages -verbose
    
            

        #    "-----------"   
            $Images
        #    "-----------" 
            
            $Link = $IE.Url

            Write-Host "Saving Shortcut"
            New-Shortcut -Link $Link -Path $DestinationPath -Verbose

            Write-Host "Saving images..." -ForegroundColor Green

            Foreach ( $I in $images ) {
                write-output $I
                try {
                        $I | Save-IEWebImage -Destination $DestinationPath -Priority 'ForeGround' -ErrorAction Stop -verbose
                    }
                    catch {
                        Write-Warning "Problem saving: $($_.Exception.Message)"
                        Write-output "Trying new base"
                        # ----- remove duplicates in the Url.  This is required for NNConnect.com
                        $I -match '.com(\/.*\/)\/'

                        $duplicates = $matches[1]

                        if ( ([regex]::Matches($I,$Duplicates )).count -gt 1 ) {
                            "$($I.Substring( 0,$I.lastindexof( $Duplicates ) ))$($I.substring($I.LastIndexOf( $Duplicates )+$duplicates.length ) )" | Save-IEWebImage -Destination $DestinationPath -Priority 'ForeGround' -ErrorAction Stop -verbose
                        }

                }
            }

            Write-Host "Opening Destination to double check if the images saved correctly" -ForegroundColor Green
            explorer $DestinationPath

            if ( (New-Popup -Message "Did it Save Correctly" -Title 'No errors' -Time 300 -Buttons 'YesNo') -eq 6 ) {
                Write-Host "Delete Shortcut" -ForegroundColor Green
                $_ | Remove-Item
            }
        }
        else {
            if ( (New-Popup -Message "Delete Shortcut?" -Title 'delete' -Time 300 -Buttons 'YesNo') -eq 6 ) {
                Write-Host "Delete Shortcut" -ForegroundColor Green
                $_ | Remove-Item
            }
   }

    # ----- Clean up
    write-host "Closing web page" -ForegroundColor Green 

    Close-IEWebPage -WebPage $IE -verbose
}