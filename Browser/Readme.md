# Remediation-Chrome-IE-Firefox-Edge-ClearUserCache.ps1
Clear Cache from 5 different browsers by using arguments. Try to delete files from the cache folder and if any deletion fails then try to close browser forcefuly and retry to delete file in the cache folder.
## USAGE
````
Remediation-Chrome-IE-Firefox-Edge-ClearUserCache.ps1 Chrome
Remediation-Chrome-IE-Firefox-Edge-ClearUserCache.ps1 IE
Remediation-Chrome-IE-Firefox-Edge-ClearUserCache.ps1 EdgeLegacy
Remediation-Chrome-IE-Firefox-Edge-ClearUserCache.ps1 EdgeChromium
Remediation-Chrome-IE-Firefox-Edge-ClearUserCache.ps1 Firefox
````
## Arguments & OS checks
Currently remediation scripts supports ARG[0]. In this senario users can provide space or comma seperated values which can than be split in the script to parse into multiple arguments. 
In this scripts $BROWSER_NAME = $ARGS[0] is only being used to clear the cache. 
## OS checks & cache path for browsers
OS checks are being made using caption from WMI Objects. Caption works on Windows 7, windows 8 as well as windows 10. 
In the scripts IE browser has been used to tackle different location of a cache. 
Browser paths are variablized and can be changes depeding on the use case.
 



