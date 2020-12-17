<#
.Synopsis
	Aternity - Remediation Script: PingConnectivityRemediation
.DESCRIPTION
	This script provides for a specifix IP/Name an availability percentage and the request time


.EXAMPLE
	Deploy in Aternity (Configuration > Remediation > Add Action) 
	Action Name: Ping host. If no parameters is set, it will ping aternity site
	Parameters : Hostname or IP.
	example :  www.google.fr | 8.8.8.8

.VERSION
	v1.0
.DATE
	Date : 12/11/2020 

#>
# Parameters
#URL
$IPTest = "www.aternity.fr"

#Variables
$ReponseCode = 0
$Availability = 0

#Parameters given in Aternity
$IPTest = $args[0]

#logic and script
try
{
	# Load Agent Module
	Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
	# Add-Type -AssemblyName PresentationCore,PresentationFramework
	# ping
	$PingResponse = Test-NetConnection $IPTest

	$Availability = 100
	# Output
	$result = "Dest IP : " + $IPTest + " | If : " + $PingResponse.InterfaceAlias + " | Remote Addr : " +  $PingResponse.RemoteAddress + " | Ping Status : " + $PingResponse.PingSucceeded  + " | Resp Time : " + $PingResponse.PingReplyDetails.RoundtripTime/1000 
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
#EOF
