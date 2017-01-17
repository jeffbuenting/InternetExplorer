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
