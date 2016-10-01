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


$Url = 'http://www.mydailytube.com/video/football-drills-15167.html'

$Url | Foreach {

    $WebPage = Get-IEWebPage -Url $_ -Visible -verbose

    $WebPage

    
    "--------------------------------------------------------------------------------------------------------------------------------------------------------"
        
    Try {
            #$DestinationPath = Get-FileorFolderPath -InitialDirectory 'p:\' -ErrorAction Stop

           # Write-Host "Destination Path = $DestinationPath" -ForegroundColor Green

            $WebPage | gm

            "+++++++++++++"

            $Videos= $WebPage | Get-IEWebVideo -verbose -ErrorAction Stop

            $Videos
    
  #          $Videos | Save-IEWebVideo -Destination $DestinationPath -Priority 'ForeGround' -ErrorAction Stop
        }
        Catch {
            $ExceptionMessage = $_.Exception.Message
            $ExceptionType = $_.Exception.GetType().FullName

            Write-Verbose "WebPage : `n $($WebPage | Out-String)"

            Throw "Problem Getting or Saving Video.`n`n     $ExceptionMessage`n     $ExceptionType"
    }

    $Link = $_

    Write-Host "Saving Shortcut"
 #   New-Shortcut -Link $Link -Path $DestinationPath -Verbose

    Write-Host "Opening Destination to double check if the images saved correctly" -ForegroundColor Green
 #   explorer $DestinationPath

 #   if ( (New-Popup -Message "Did it Save Correctly" -Title 'No errors' -Time 300 -Buttons 'YesNo') -eq 6 ) {
 #       write-host "Didn't Save,Will write to log" -ForegroundColor Green
 #       $ImageSaveIssue += $L
 #   }

    #$WebPage | gm

  #  Close-IEWebPage -WebPage $WebPage -Verbose
}





