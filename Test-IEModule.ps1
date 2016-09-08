Import-Module D:\Scripts\Modules\InternetExplorer\InternetExplorer.psm1

#$WebPage = Open-IEWebPage -Url "http://www.huskermax.com/games/2014/vid/00a/m_mon18practice.html"
#Get-IEWebPageElementbyTagName -ie $WebPage -ElementTagName "Embed" -verbose

#Get-IEWebPageVideo -Url "https://www.youtube.com/embed/--Z13x6kvSM?wmode=opaque" -Folder 'd:\temp\videos' -verbose

#Get-IEWebFile -Url "https://www.youtube.com/embed/--Z13x6kvSM?wmode=opaque" -FileName 'd:\temp\videos\tripleoption.flv'

#Get-IEWebFile -VideoUrl "https://www.youtube.com/watch?v=--Z13x6kvSM" -Folder 'd:\temp\videos'
Get-IEVideoUrls -Url "http://www.tizag.com/htmlT/htmlvideocodes.php" -verbose


#$btns = $WebPage.document.getElementsByTagName("input")
#$SearchText = $btns | ? { $_.Name -eq "q" }
#$SearchText.value = "Huskermax"
#$SearchButton = $btns | ? { $_.Name -eq "btnG" }
#$SearchButton.click()




