<#
.Synopsis
	Aternity - Remediation Script: TCPConnectivityRemediation
.DESCRIPTION
	This script provides for a specifix IP/Name and Port an availability percentage and the request time


.EXAMPLE
	Deploy in Aternity (Configuration > Remediation > Add Action) 
	Action Name: Script checks the TCP connection status it will ping aternity site
	Parameters : Hostname or IP and port
	example :  www.google.fr | 8.8.8.8;80

.VERSION
	v1.0
.DATE
	Date : 12/11/2020 
#>
# Parameters
#Host name and port by default
$IPTest = "www.aternity.fr"
$Port = 80

#Variables
$ReponseCode = 0
$Availability = 0

$arguments = $args[0].split(";")

#Remote host
if (!($arguments[0].trim() -eq "")) 
	{
	[string] $IPTest = $arguments[0].trim()
	}
#Folder	
if (!($arguments[1].trim() -eq "")) 
	{
	[int] $Port = $arguments[1].trim()
	}

#logic and script
try
{
	# Load Agent Module
	Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
	#Add-Type -AssemblyName PresentationCore,PresentationFramework

	#TCP Test
	$PingResponse = Test-NetConnection $IPTest -port $Port

	#Output
	$result = "Computer Name  : " + $PingResponse.ComputerName + " | Port : " + $Port + " | If : " + $PingResponse.InterfaceAlias + " | Remote Addr : " +  $PingResponse.RemoteAddress + " | TCP Status : " + $PingResponse.TcpTestSucceeded
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
#EOF
