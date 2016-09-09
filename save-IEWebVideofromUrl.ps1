$Url = "http://alisakiss.com/trailer/trailer.mp4"

 $DestinationPath = Get-FileorFolderPath -InitialDirectory 'p:\'

 foreach ( $U in $Url ) {
    write-host "saving $U" -foreground Green

    $U | Save-IEWebVideo -Destination $DestinationPath -Priority 'ForeGround'

   
}

 Write-Host "Opening Destination to double check if the images saved correctly" -ForegroundColor Green
    explorer $DestinationPath

    (New-Popup -Message "Did it Save Correctly" -Title 'No errors' -Time 300 -Buttons 'YesNo') 