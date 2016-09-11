import-module C:\scripts\InternetExplorer\InternetExplorer.psd1 -force
Import-Module C:\scripts\FileSystem\filesystem.psd1 -force
Import-Module c:\scripts\popup\popup.psm1 -force
Import-Module C:\scripts\Shortcut\Shortcut.psm1


$Url = ''

$Url | Foreach {

    $WebPage = Get-IEWebPage -Url $_ -Visible -verbose

    $WebPage

"--------------------------------------------------------------------------------------------------------------------------------------------------------"
        
    $DestinationPath = Get-FileorFolderPath -InitialDirectory 'p:\'

   # Write-Host "Destination Path = $DestinationPath" -ForegroundColor Green

    $Images = $WebPage | Get-IEWebVideo -verbose 
    
    $Images | Save-IEWebVideo -Destination $DestinationPath -Priority 'ForeGround'

    $Link = $_

    Write-Host "Saving Shortcut"
    New-Shortcut -Link $Link -Path $DestinationPath -Verbose

    Write-Host "Opening Destination to double check if the images saved correctly" -ForegroundColor Green
    explorer $DestinationPath

    if ( (New-Popup -Message "Did it Save Correctly" -Title 'No errors' -Time 300 -Buttons 'YesNo') -eq 6 ) {
        write-host "Didn't Save,Will write to log" -ForegroundColor Green
        $ImageSaveIssue += $L
    }

    #$WebPage | gm

    Close-IEWebPage -WebPage $WebPage -Verbose
}





