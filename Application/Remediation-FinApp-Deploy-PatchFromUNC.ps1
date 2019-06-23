<#
.Synopsis
   Aternity - Remediation Script: Deploy FinApp Patch1903
.DESCRIPTION
	Download from unc (SMB fileshare) and install patch03 for FinApp (custom Desktop application) which comes as a binary (.exe)
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Deploy FinApp Patch1903
   Description: Download and install patch 1903 for FinApp
   Run the script in the System account: checked
   Requires confirmation: No
#>

# script variable to set
$id = "finapp-patch1903"
$unc = "\\fileserver\applications\finapp\patch1903.exe"
$installer = "patch1903.exe"
###

try
{
	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
	
	#region Remediation action logic

		# Add your remediation code here and set the variable $result with the Output Message to be visible visible in Aternity's dashboards.
		#
		# For example:
		# 	Clear-DnsClientCache
		# 	$result="DNS Cache Cleared"

# download installer
$timestamp = $(Get-Date -Format "yyMMddHHmmss")
$tempDir = "$env:TEMP\$id-$timestamp"
if (Test-Path -Path $tempDir) { throw "Folder  $tempDir already exist" }
New-Item $tempDir -ItemType Directory
robocopy /r:5 /w:30 $unc $tempDir $installer
$installerPath = "$tempDir\$installer"
if (! (Test-Path -Path $installerPath)) { throw "Installer $installerPath is missing" }

# run installer
Start-Process -FilePath $installerPath -WorkingDirectory $tempDir

# check
if ($? -ne 0) { throw "Installer $installer issue" }

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}