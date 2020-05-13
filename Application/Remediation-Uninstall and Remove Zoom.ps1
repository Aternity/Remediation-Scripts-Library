try
{
    # Uninstalls Zoom application and removes respective Zoom installation directory
    # Set new environment for Action Extensions Methods 
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
[string]$uninstaller = "$env:USERPROFILE\AppData\Roaming\Zoom\uninstall\installer.exe"
       
        If(Test-Path -Path $uninstaller){
            $initiating = "$uninstaller exists. Initiating uninstall"
            start-process "$env:USERPROFILE\AppData\Roaming\Zoom\uninstall\installer.exe" -ArgumentList "/uninstall" -Wait -WindowStyle Hidden
            
        }else{
            $initiating = "$uninstaller does NOT exist. Nothing to uninstall...."
        }
       
     
     if(Test-Path -Path "$env:Appdata\Zoom\")
     
     {
     
     Remove-Item "$env:USERPROFILE\AppData\Roaming\Zoom\" -Force  -Recurse
      
     } 
   

	
		[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($initiating)
	
    
}
catch
{
	
 #[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}