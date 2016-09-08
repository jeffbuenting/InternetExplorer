Function Test-IEWebPath {

<#
    .Synopsis
        Checks if a web path exists

    .Description
        Used to check if a web path exists.  For example.  Is the address to a JPG valid.

    .Parameter Url
        Address to the Web Path to test

    .Example
        test if the following JPG exists at the specified webpage

        Test-IEWebPath -Url http://www.contoso.com/award.jpg

    .Link
        http://stackoverflow.com/questions/20259251/powershell-script-to-check-the-status-of-a-url
#>
    
    [CmdletBinding()]
    Param (
        [String]$Url
    )


    # First we create the request.
    $HTTP_Request = [System.Net.WebRequest]::Create($Url)

    # We then get a response from the site.
    $HTTP_Response = $HTTP_Request.GetResponse()

    # We then get the HTTP code as an integer.
    $HTTP_Status = [int]$HTTP_Response.StatusCode

    If ($HTTP_Status -eq 200) { 
        Write-Output $True 
    }
    Else {
        Write-Output $Fals
    }

    # Finally, we clean up the http request by closing it.
    $HTTP_Response.Close()
}

Test-WebPath -Url http://www.nnconnect.com/destiny_moody/teeny_blue/destiny_moody-04.jpg