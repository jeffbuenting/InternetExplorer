try {
        import-module C:\Scripts\InternetExporer\InternetExplorer.psd1 -force -ErrorAction Stop
        Import-Module C:\scripts\FileSystem\filesystem.psd1 -force -ErrorAction Stop
        Import-Module C:\scripts\InternetExporer\p\p.psd1 -force -ErrorAction Stop
        Import-Module c:\scripts\popup\popup.psm1 -force -ErrorAction Stop
        Import-Module C:\scripts\Shortcut\Shortcut.psm1 -Force -ErrorAction Stop
    }
    Catch {
        $ExceptionMessage = $_.Exception.Message
        $ExceptionType = $_.Exception.GetType().FullName
        Throw "Problem importing modules.`n`n     $ExceptionMessage`n     $ExceptionType"
}

$Links = Import-CSV -Path 'P:\links\savepics.csv'


$VerboseTest = $True

$ImageSaveIssue = @()
$FileExists = @()

foreach ( $L in $Links ) {

    write-host "Link:  $($L.Url)" -ForegroundColor Green
    Write-Host "Path:  $($L.Path)" -ForegroundColor Green

    $IE =  $L.Url | Get-IEWebPage -Visible -verbose

    # ----- Manually get the save path if one is not in the CSV
    if ( -Not ( $L.Path ) ) {
            $DestinationPath = Get-FileorFolderPath -InitialDirectory 'p:\'
            if ( -Not $DestinationPath ) { Continue }
        }
        else {
            $DestinationPath = $L.Path
            If ( -Not (Test-Path $DestinationPath) ) {
                    Write-Host "Creating Directory $DestinationPath" -ForegroundColor Green
                    MD $DestinationPath
                }
                else {
                     
                    Write-Host "Destination already Exists: $destinationPath" -ForegroundColor Yellow
                    Write-Host "Opening Destination to double check if the images already exist" -ForegroundColor Green
                    explorer $DestinationPath
                    if ( (New-Popup -Message "Do the images already exist?" -Title 'No errors' -Time 300 -Buttons 'YesNo') -eq 6 ) {
            
                    }
                    # ----- Save link to write to log
                    $FileExists += $L
                    Continue
            }
                    
    }

  
   

    $Images = $Null


    $Images = $IE | Get-PImages -verbose
    
    "-----------"   
    $Images
    "-----------" 

            
    $Link = $IE.Url

    Write-Host "Saving Shortcut"
    New-Shortcut -Link $Link -Path $DestinationPath -Verbose

    Write-Host "Saving images..." -ForegroundColor Green
    $Images | Save-IEWebImage -Destination $DestinationPath -Priority 'ForeGround' -verbose

            
    If ( $VerboseTest ) {
            Write-Host "Opening Destination to double check if the images saved correctly" -ForegroundColor Green
            explorer $DestinationPath

            if ( (New-Popup -Message "Did it Save Correctly" -Title 'No errors' -Time 60 -Buttons 'YesNo') -eq 6 ) {
                write-host "Didn't Save,Will write to log" -ForegroundColor Green
                $ImageSaveIssue += $L
            }
        }
        else { 
            If ( $Images -eq $Null ) {
                write-host "Didn't Save,Will write to log" -ForegroundColor Green
                $ImageSaveIssue 
            }
    }

        


    # ----- Clean up
    write-host "Closing web page" -ForegroundColor Green 

    Close-IEWebPage -WebPage $IE -verbose


}

Write-Host "Writing to error logs" -ForegroundColor Green
$ImageSaveIssue | export-csv p:\links\ImageSaveIssues.csv -NoTypeInformation -Append
$FileExists | Export-CSV p:\links\FileExists.csv -NoTypeInformation -Append


Remove-Module InternetExplorer