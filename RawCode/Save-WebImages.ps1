function Resolve-ShortcutFile {
     
<#
    .Description
        Retrieves the web page address (U RL) from a shortcut.
    .Parameter FileName
        Full Path to the shortcut
    .Parameter FilterString
        String to filter.  If the wep page address is 'Like' this string then it will be returned.  Otherwise it will be skipped.
    .LINK
        http://blogs.msdn.com/b/powershell/archive/2008/12/24/resolve-shortcutfile.aspx
#>          
           
    [CmdLetBinding()]
    param(
        [Parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0)]
        [Alias("FullName")]
        [string]
        $fileName,

        [String]$LikeString = $Null
    )
    
    process {
        
        Write-Verbose "Processing $_"
        if ( $LikeString -ne $Null ) {
                if ($fileName -like "*.url") {
                    Write-Verbose "Filtering Urls"
                    $ShortCut = Get-Content $fileName | Where-Object { $_ -like "url=*" -and $_ -like "*$LikeString*" } 
                    if ( $ShortCut -ne $Null ) {
                        Write-Output ( New-Object -Type PSObject -Property @{'FileName'= $FileName; 'Url' = $ShortCut.Substring($ShortCut.IndexOf("=") + 1 ) } )
                    }
                }
            }
            Else {
                if ($fileName -like "*.url") {
                    Write-Verbose "Returning all Urls"
                    $ShortCut = Get-Content $fileName | Where-Object { $_ -like "url=*" } 
                    Write-Output ( New-Object -Type PSObject -Property @{'FileName'= $FileName; 'Url' = $ShortCut.Substring($ShortCut.IndexOf("=") + 1 ) } )

                }  
       }          
    
}

}  

Function AGet-IEWebPageImage {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [String]$Url,

        [Switch]$Visible
    )

    Process {
        foreach ( $U in $Url ) {
            Write-Verbose "Processing $U..."

            $ie = New-Object -COMObject InternetExplorer.Application
            if ($Visible) { $ie.visible = $true }
            $ie.Navigate($U)
            While ($ie.Busy) { Start-Sleep -Milliseconds 400 }

            $ie.document.getElementsByTagName('img') | Write-Output

        }
    }

}



Import-Module C:\scripts\InternetExplorer\internetexplorer.psm1

$RootPath = 'p:\links\2009DEC'
#$Url = 'http://www.powershell.com'
$Url = 'http://powershell.org/wp/'

#get-childitem -path $RootPath | Resolve-ShortcutFile -LikeString 'Nikki Sims Sweater'| FL *

Get-IEWebPageImage -Url $Url #-verbose

remove-module Internetexplorer