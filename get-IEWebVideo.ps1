#--------------------------------------------------------------------------------------
# Downloads videos from web page
#
# Version : 2.0
#
# Author : Jeff Buenting
#--------------------------------------------------------------------------------------

try {
        import-module C:\Scripts\InternetExporer\InternetExplorer.psd1 -force -ErrorAction Stop
        Import-Module C:\scripts\FileSystem\filesystem.psd1 -force -ErrorAction Stop
        Import-Module c:\scripts\popup\popup.psm1 -force -ErrorAction Stop
        Import-Module C:\scripts\Shortcut\Shortcut.psm1 -Force -ErrorAction Stop
    }
    Catch {
        $ExceptionMessage = $_.Exception.Message
        $ExceptionType = $_.Exception.GetType().FullName
        Throw "Problem importing modules.`n`n     $ExceptionMessage`n     $ExceptionType"
}


$Url = 'http://xxxbunker.com/gianna_michaels_has_huge_tits'

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





