try
{
    # Set new environment for Action Extensions Methods 
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
    #$DomainUser = $env:username
	$user = $args[0]
    $LocalGroup = 'Administrators'
    $Computer   = $env:computername
    $Domain     = $env:userdomain
    $group = [ADSI]('WinNT://'+$env:COMPUTERNAME+'/administrators,group')
    $group.psbase.Invoke('Add',([ADSI]"WinNT://$Domain/$user").path)

	
		[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($user)
	
    
}
catch
{
	
 [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}