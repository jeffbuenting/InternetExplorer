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


$Url = 'http://www.mydailytube.com/video/new-years-resolution-ii-15597.html'

$Url | Foreach {

    $WebPage = Get-IEWebPage -Url $_ -Visible -verbose

    #$WebPage  

    Write-Verbose "WebPage : `n $($WebPage | Out-String)"
    
    "--------------------------------------------------------------------------------------------------------------------------------------------------------"
      
    # ----- Get the folder to save the file  
    Try 
    {
        $DestinationPath = Get-FileorFolderPath -InitialDirectory 'p:\' -ErrorAction Stop -Verbose

        Write-Host "Destination Path = $DestinationPath" -ForegroundColor Green

        #  $WebPage | gm

        "+++++++++++++"
    }
    Catch 
    {
        $ExceptionMessage = $_.Exception.Message
        $ExceptionType = $_.Exception.GetType().FullName
        Throw "Error Getting Destination path to save the video.`n`n     $ExceptionMessage`n     $ExceptionType"
    }

    # ----- Find any videos on the web page
    Try 
    {
        $Videos= $WebPage | Get-IEWebVideo -verbose -ErrorAction Stop
        $Videos
    }
    Catch 
    {
        $ExceptionMessage = $_.Exception.Message
        $ExceptionType = $_.Exception.GetType().FullName
        Throw "Error Getting Video.`n`n     $ExceptionMessage`n     $ExceptionType"
    }

    # ----- Save the video
    Try 
    {  
        $Videos | Save-IEWebVideo -Destination $DestinationPath -Priority 'ForeGround' -ErrorAction Stop
    }
    Catch 
    {
        $ExceptionMessage = $_.Exception.Message
        $ExceptionType = $_.Exception.GetType().FullName
        Throw "Problem Saving Video.`n`n     $ExceptionMessage`n     $ExceptionType"
    }

    # ----- Save the shortcut
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





