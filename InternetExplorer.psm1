#------------------------------------------------------------------------------
# Module InernetExplorer
#
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function Get-IEWebPageImages
#
# Downloads all image files from the specified URL
#------------------------------------------------------------------------------

 Function Get-IEWebPageImage {

 	<#
		.SYNOPSIS
			Downloads all image files from the WebPage Object

		.DESCRIPTION
			Analyzes the web page object for images and returns them.

		.PARAMETER WebPage 
            Web Page object returned from Open-IEWebPage.
		
		.Example
			Get-IEWebPageImage -WebPage $IE

        .Example 
            Open-IEWebPage -Url "http://www.powershell.org" | Get-IEWebPageImage

		.Link
			http://powershell.com/cs/blogs/tobias/archive/2010/03/17/downloading-images-from-webpages.aspx
    #>

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [System.__ComObject[]]$WebPage
    )

    Process {
        foreach ( $WP in $WebPage ) {
  
            Write-Verbose "Getting Images from $($WP.LocationUrl)..."

            $WP.document.getElementsByTagName('img') | Write-Output

        }
    }

}

#------------------------------------------------------------------------------

Function Save-IEWebImage {

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

#>


    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [System.__ComObject]$WebImage,

        [String]$Destination 
    )

    Begin {
        Import-Module BitsTransfer

	    if (-not (Test-Path $Destination)) { md $Destination }
    }
    
    Process {
        Write-Verbose "Processing $($WebImage.SRC)"
        
        Start-BitsTransfer -Source $WebImage.SRC -Destination "$Destination\$($WebImage.SRC.Split('/')[-1])" -Priority High -DisplayName "$Destination\$($WebImage.SRC.Split('/')[-1])" 
    }
}

#------------------------------------------------------------------------------
# Function Wait-IEWebPageLoad
#
# Helper function that waits until the web page has loaded.  
# http://www.pvle.be/2009/06/web-ui-automationFunction Wait-IEWebPageLoad
#test-using-powershell/
#------------------------------------------------------------------------------

Function Wait-IEWebPageLoad {

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

#------------------------------------------------------------------------------
# Function Open-IEWebPage 
#
# Opens Web Page.  Returns object holding web page
# http://www.pvle.be/2009/06/web-ui-automationFunction Wait-IEWebPageLoad
#test-using-powershell/
#------------------------------------------------------------------------------

Function Open-IEWebPage {

	[CmdLetBinding()]
	Param ( 
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [string]$url, 
	
    	[int]$delayTime = 400,

        [Switch]$Visible
    )

    Process {
        Write-Verbose "Navigating to $Url"

        $ie = New-Object -com "InternetExplorer.Application"
	    if ($Visible) { $ie.visible = $true }
  	    $ie.Navigate($url)
        While ($ie.Busy) { Start-Sleep -Milliseconds $DelayTime }

        Write-Output $IE
  }
	  
}

#------------------------------------------------------------------------------

Function Close-IEWebPage {

    [CmdLetBinding()]
	Param ( 
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [System.__ComObject[]]$WebPage
    )

    Process {
        Foreach ( $WP in $WebPage ) {
            Write-Verbose "Closing $($WP.LocationUrl)"
            
            $WP.Quit()
        }
    }
}



#------------------------------------------------------------------------------
# Function Set-IEWebPageElementByName
#
# Fill in specified input filed
# http://www.pvle.be/2009/06/web-ui-automationFunction Wait-IEWebPageLoad
#test-using-powershell/
#------------------------------------------------------------------------------

Function Set-IEWebPageElementbyName {

	[CmdLetBinding()]	
	param( $ie,
			[String]$ElementName,
			[String]$NewValue,
			[String]$Position = 0 )
			
	Write-Verbose $IE.Document
			
	if ( $IE.Document -eq $null) {
    	Write-Error "Document is null";
   		 break
  	}
	
  	$elements = @($IE.doc.getElementsByName($ElementName))
  	if ($elements.Count -ne 0) {
    		$elements[$position].Value = $NewValue
  		}
  		else {
    		Write-Warning "Couldn't find any element with name:$ElementName";
  	}
}

#------------------------------------------------------------------------------
# Function Get-IEWebPageElementByTagName
#
# Fill in specified input filed
# http://www.pvle.be/2009/06/web-ui-automationFunction Wait-IEWebPageLoad
#test-using-powershell/
#------------------------------------------------------------------------------

Function Get-IEWebPageElementbyTagName {

	[CmdLetBinding()]	
	param( $ie,
			[String]$ElementTagName )
			
	Write-Verbose $ElementTagName
			
	if ( $IE.Document -eq $null) {
    	Write-Error "Document is null";
   		 break
  	}
	
  	$elements = $IE.document.getElementsByTagName($ElementTagName)
  	
	Return $Elements
}

#------------------------------------------------------------------------------
# Function Get-IEWebFile
#
# Download Video from web page
#------------------------------------------------------------------------------

function Get-IEWebFile {

	<#
		.SYNOPSIS
			Downloads video from web  page
		
		.Link
			http://jacob.ludriks.com/downloading-from-youtube-using-powershell/
	#>

	[CmdLetBinding()]
	param ( [Parameter(Mandatory=$True)] [string]$VideoUrl,
			[String]$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome,
			[String]$itag = '22',
			[String]$Folder )

	# ----- Potential values for Itag
	$quality = @{}
	$quality["5"] = @{"ext"="flv";"width"=400;"height"=240}
	$quality["6"] = @{"ext"="flv";"width"=450;"height"=270}
	$quality["13"] = @{"ext"="3gp"}
	$quality["17"] = @{"ext"="3gp";"width"=176;"height"=144}
	$quality["18"] = @{"ext"="mp4";"width"=640;"height"=360}
	$quality["22"] = @{"ext"="mp4";"width"=1280;"height"=720}
	$quality["34"] = @{"ext"="flv";"width"=640;"height"=360}
	$quality["35"] = @{"ext"="flv";"width"=854;"height"=480}
	$quality["36"] = @{"ext"="3gp";"width"=320;"height"=240}
	$quality["37"] = @{"ext"="mp4";"width"=1920;"height"=1080}
	$quality["38"] = @{"ext"="mp4";"width"=4096;"height"=3072}
	$quality["43"] = @{"ext"="webm";"width"=640;"height"=360}
	$quality["44"] = @{"ext"="webm";"width"=854;"height"=480}
	$quality["45"] = @{"ext"="webm";"width"=1280;"height"=720}
	$quality["46"] = @{"ext"="webm";"width"=1920;"height"=1080}
	 
	# ----- Grab web page 
	$content = Invoke-WebRequest -Uri $videoUrl -UserAgent $userAgent
	# ----- Extract Title
	$title = $content | Select-String -Pattern '(?i)<title>(.*)<\/title>' | %{ $_.matches.groups[1].value }
	# ----- Extract Potential Video URLs
	$html = $content | Select-String -Pattern '"url_encoded_fmt_stream_map":\s"(.*?)"' | %{ $_.matches.groups[1].value }
	$html = $html -replace "%3A",":"
	$html = $html -replace "%2F","/"
	$html = $html -replace "%3F","?"
	$html = $html -replace "%3D","="
	$html = $html -replace "%252C","%2C"
	$html = $html -replace "%26","&"
	$html = $html -replace "\\u0026","&"
	$urls = $html.split(",")
	$urls | Select-String -Pattern 'itag=(\d+)' | % {
		$val = $_.matches.groups[1].value
		Write-Host $val") Extension:" $quality[$val].ext "Dimensions:" $quality[$val].width"x"$quality[$val].height
	}
	$Urls
	
	# ---- Save video that matches specified quality
	foreach ($url in $urls) {
		$string = "itag=$itag"
		$String
		if ($url -match $string) {
			"-----"
			$Url
			$signature = $url | Select-String -Pattern '(s=[^&]+)' | %{ $_.matches.groups[1].value }
			$url = $url | Select-String -Pattern '(http.+)' | %{ $_.matches.groups[1].value }
			$url = $url -replace "(type=[^&]+)",""
			$url = $url -replace "(fallback_host=[^&]+)",""
			#$url = $url -replace "(quality=[^&]+)",""
			$download = $url
			$download = $download -replace "&+","&"
			$download = $download -replace "&$",""
			$download = $download -replace "&itag=\d+",""
			$download = "$download&itag=$itag"
			Invoke-WebRequest -Uri $download -OutFile "$Folder\$title.$($quality[$itag].ext)" -UserAgent $useragent
		}
	}
}

#------------------------------------------------------------------------------
# Function Get-IEVideoUrls
#
# Returns the video Source Urls from a web page
#------------------------------------------------------------------------------

Function Get-IEVideoUrls {

	[CmdLetBinding()]
	param ( [String]$Url,
	[String]$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome )
	
	# ----- Grab web page 
#	$content = Invoke-WebRequest -Uri $Url -UserAgent $userAgent
	Get-Content -Path d:\Temp\content.txt
#	$Content.content
	$VideoUrls = $content | Select-String -Pattern 'embed SRC="([^"]*)' | %{ $_.matches.groups[1].value }
	"----"
	$VideoUrls
	
}

#------------------------------------------------------------------------------

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

#Export-ModuleMember -Function Open-IEWebPage,Set-IEWebPageElementbyName,Get-IEWebPageElementbyTagName,Get-IEWebFile, Get-IEVideoUrls