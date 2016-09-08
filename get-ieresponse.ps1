Function Get-IEResponse {
    
<#
    .Link
        http://stackoverflow.com/questions/1473358/how-to-obtain-numeric-http-status-codes-in-powershell
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String]$Url
    )

    Process {
        Write-Verbose "Getting website Respose for: $Url"
        $Request = [System.Net.HttpWebRequest]::Create($Url)
        try {
                $Response = $Request.GetResponse() 
            }
            Catch {
                Write-Verbose "Error getting Response"
                $Response = $Error[0].Exception.InnerException.Response
        }

       # if ( -Not $Resonse ) { $Response = $Error[0].Exception.InnerException.Response }

        Write-Verbose "Status = $([Int]$Response.StatusCode)"
        
        $Response | Add-Member -MemberType NoteProperty -Name 'Status' -Value ([Int]$Response.StatusCode)
        Write-Output $Response
    }
}

'http://www.nnconnect.com/pattycake_online/red_dress//pattycake_online/red_dress/pattycake_online-12.jpg' | Get-IEResponse -Verbose

'http://www.nnconnect.com/pattycake_online/red_dress/pattycake_online-12.jpg' | Get-IEResponse -Verbose
 
