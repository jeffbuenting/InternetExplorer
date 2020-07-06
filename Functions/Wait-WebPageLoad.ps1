#------------------------------------------------------------------------------
# Function Wait-IEWebPageLoad
#
# Helper function that waits until the web page has loaded.  
# http://www.pvle.be/2009/06/web-ui-automationFunction Wait-IEWebPageLoad
#test-using-powershell/
#------------------------------------------------------------------------------

Function Wait-WebPageLoad {

	[CmdLetBinding()]
	Param ( $ie,
			[int]$delayTime = 100)

	Write-Verbose "Waiting for Web Page to Load"
  	$loaded = $false
 
  	while ($loaded -eq $false) {
    	[System.Threading.Thread]::Sleep($delayTime) 
 
    	#If the browser is not busy, the page is loaded
    	if (-not $ie.Busy){
      		$loaded = $true
    	}
  	}
	Return $ie
}

New-Alias -Name Wait-IEWebPageLoad -Value Wait-WebPageLoad