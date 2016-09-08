

#--------------------------------------------------------------------------------------

Import-module c:\scripts\Modules\InternetExplorer\InternetExplorer.psm1
Import-Module C:\scripts\FilesandFolders\filesandfolders.psm1
Import-Module c:\scripts\modules\popup\popup.psm1
import-module C:\scripts\Modules\Porn\porn.psm1

   
    $IE = 'http://www.hqbabes.com/Nikki+Sims+-+Nikki+Waiting+In+Bed+For+You-257730/' | Get-IEWebPage -Visible
    #write-Host "$($IE.LocationUrl)" -ForegroundColor DarkYellow

    $IE | Get-PornImages -verbose


    Close-IEWebPage -WebPage $IE -ErrorAction Stop 
       


Remove-Module InternetExplorer
Remove-Module FilesandFolders
Remove-Module Porn





