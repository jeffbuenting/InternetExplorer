Function Save-WebPageImage {

<#
    .Description
        Copies an image from a web page to the destination folder.  
    
    .Parameter WebImage
        Image obtained from a webpage.  Use Get-IEWebImage to retrieve web images from a page.
        
    .Parameter Destiniation
        Path name where the image will be copied.
        
    .Example
         Get-IEWebPageImage -url $Url | Save-IEWebImage -Destination 'd:\temp\test'

         Copies all images retrieved from $Url web page to d:\temp\test. 

    .Link
        http://www.powershellatoms.com/basic/download-file-website-powershell/
#>

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [String[]]$Source,
        
        [String]$Destination,

        [String]$FileName,

        [ValidateSet('ForeGround','High','Normal','Low',IgnoreCase=$True)]
        [String]$Priority = 'Normal',

        [Switch]$BackGround,

        [Switch]$Wait
    )

    Begin {
       # Import-Module BitsTransfer

	    if (-not (Test-Path $Destination)) { md $Destination }
    }

    Process {
        Foreach ( $S in $Source ) {
            Write-Verbose "Saving $S"
            
            Try {
                If ( $Background ) {
                        $BitsJob = Start-BitsTransfer -Source $S -Destination $Destination -Description $S -Priority $Priority -Asynchronous -errorAction Stop
                    }
                    else {
                        $BitsJob = Start-BitsTransfer -Source $S -Destination $Destination -Description $S -Priority $Priority -ErrorAction Stop
                }
            }
            Catch {
                $ExceptionMessage = $_.Exception.Message
                $ExceptionType = $_.Exception.GetType().FullName
                Write-Verbose "Destination = $Destination"
                Write-Verbose "DisplayName = $DisplayName"
                
                Write-Warning "$($MyInvocation.InvocationName) : Problem Saving with Bits. Trying with Invoke-WebRequest.`n`n     $ExceptionMessage`n     $ExceptionType"

                # ----- Extract file name from URL if not supplied
                if ( -Not $FileName ) { $FileName = ($S.split('/' ))[-1] }

                Try {
                    #$URI = New-Object system.uri -ArgumentList $
                    Invoke-WebRequest -uri $S -OutFile $Destination\$FileName -ErrorAction Stop
                }
                Catch {
                    $ExceptionMessage = $_.Exception.Message
                    $ExceptionType = $_.Exception.GetType().FullName
                    Write-Verbose "Source = $Source"
                    Write-Verbose "Destination = $Destination"
                    Write-Verbose "FileName = $FileName"

                    Throw "$($MyInvocation.InvocationName) : Invoke-WebRequest.`n`n     $ExceptionMessage`n     $ExceptionType"

                }
            }

            if ( $Wait ) {
                Write-Verbose "Waiting for Bits Transfer to complete"
                While ( ( $BitsJob.JobState -ne 'Error' ) -or ( $BitsJob -ne 'Transferred' ) ) {
                    Sleep -Seconds 15
                }
            }
   
        }

    }

}

New-Alias -Name Save-IEWebImage -Value Save-WebPageImage