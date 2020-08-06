<#
.SYNOPSIS
Delete Skype/Lync cache folder

.DESCRIPTION
Deletes the Skype for Business and Lync cache to force autodiscover.
#>

try
{
	# Load Aternity Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

#Step 1: stop the lync.exe process before proceeding

Stop-Process -name lync -Force
Start-Sleep -s 3

#Step 2: test if Office 2013 or 2016 are in use, and delete the folder and contents called sip_<username>
if(Test-Path -Path $env:USERPROFILE\AppData\Local\Microsoft\Office\16.0\Lync)
{
Get-ChildItem -Path $env:USERPROFILE\AppData\Local\Microsoft\Office\16.0\Lync -Filter "sip_*" | remove-item -force -Recurse
}
else {
        if(Test-Path -Path $env:USERPROFILE\AppData\Local\Microsoft\Office\15.0\Lync)
        {
        Get-ChildItem -Path $env:USERPROFILE\AppData\Local\Microsoft\Office\15.0\Lync -Filter "sip_*" | remove-item -force -Recurse
        }
        else
        {
        #does not exist
        }
    #neither exists and do nothing
    }
#Then Start the Skype for Business Client
Start-Sleep -s 3
Start-Process lync.exe
    #[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
} 