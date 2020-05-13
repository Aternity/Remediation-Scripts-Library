<#
.Synopsis
   Aternity - Remediation Script: Update McAfee AV Signature v1.2
.DESCRIPTION
	Check for McAfee AV running on the system, and if so, update signatures and confirm update. 
	Checks to see if McAfee is running, whether the signatures are more than 7 days old and forces an update. 
	If the update is successful it also forces a MS MDM intune update to notify (Get-ScheduledTask | ? {$_.TaskName -eq 'PushLaunch'} | Start-ScheduledTask).
	
	References:
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Update McAfee AV Signature
   Description: Check for McAfee AV running on the system, and if so, update signatures and confirm update.
   Run the script in the System account: unchecked (must run in the current user context)??
#>

try
{
	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
	
#region Remediation action logic

    # Check that McAffee is Installed and Service is Running
	$mcAfeeIsRunning = Get-Process mcshield -ErrorAction SilentlyContinue   #mcshield
	if ($mcafeeIsRunning) {
        
		# Update McAfee Antivirus signature
		#"C:\Program Files\McAfee\Endpoint Security\Threat Prevention\amcfg.exe /update"
		cmd /c "C:\Program Files\McAfee\Endpoint Security\Threat Prevention\amcfg.exe" /update

        # Pop Up Notification Window
        #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        #$oReturn=[System.Windows.Forms.Messagebox]::Show("McAfee antivirus is being updated .. please be patient..")

		$currentdate = Get-Date
		
        [decimal]$i=0
		
        for ($i=0; $i -le 6;$i++) {
		
        # Check Datestamps for update confirmation
		$val=(Get-ItemProperty -path 'HKLM:\SOFTWARE\McAfee\AVSolution\DS\DS').szContentCreationDate
        $avdate = Get-Date $val
		
		$age = $currentdate - $avdate
		$days = ($age).days

			# Confirm AV Signature has been updated...
			if ($days -lt 5) {
				$result="Successfully Updated McAfee Av Signature"
				Get-ScheduledTask | ? {$_.TaskName -eq 'PushLaunch'} | Start-ScheduledTask
				$i = 7
				} else {
                "Failed"
				$result="McAfee Failed to update AV Signatures in 120 secs"
				start-sleep -seconds 20
			    }
		}
		
	} else {
    # McAfee not found ??  
     "Not Found"
     $result="McAfee NOT found on device"
 	}
 
#endregion

	# Set Output message
    #$result
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    #"END Script"
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
