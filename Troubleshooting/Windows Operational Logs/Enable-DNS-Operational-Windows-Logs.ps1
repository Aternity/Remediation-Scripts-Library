try
{
    # Load Agent Module
	Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
    #Enabling the DNS Client Operational Event logs
    wevtutil.exe sl Microsoft-Windows-DNS-Client/Operational /e:true /ms:8388608 /rt:false
    sleep 2
	#checking the status of logs enabled or not and setting the script output
	$result = Get-WinEvent -ListLog Microsoft-Windows-DNS-Client/Operational | format-list IsEnabled | Out-String
	$charArray =$result.Split(":")
	$result101 = $charArray[1]
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput("Microsoft-Windows-DNS-Client/Operational Event Logs are Enabled & set to$result101")
}
catch 
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
