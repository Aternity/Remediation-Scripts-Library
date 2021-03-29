<#
.Synopsis
	Aternity - Remediation Script: Remediation-TraceRoute
	This script the result of traceroute to a specific node on the network.
	THe output is limited to 1024 Characters


.EXAMPLE
	Deploy in Aternity (Configuration > Remediation > Add Action) 
	Action Name: Tracert. If no destination is set, it will do a trace route to www.aternity.com
	Parameters : Hostname or IP.
	example :  www.google.fr | 8.8.8.8

.VERSION
	v1.0
.DATE
	Date : 29/03/2021
#>


$result=""
$RemoteHost = "www.aternity.com"

try
{
# Set new environment for Action Extensions Methods
Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

#Retrieve parameters

if (!($args[0] -eq ""))
	{
	$RemoteHost = $args[0]
	}

	tracert $RemoteHost |ForEach-Object{
		if($_.Trim() -match "Tracing route to .*") {
			Write-Host $_ -ForegroundColor Green
		} elseif ($_.Trim() -match "^\d{1,2}\s+") {
			$n,$a1,$a2,$a3,$target,$null = $_.Trim()-split"\s{2,}"
			$Properties = @{
				Hop    = $n;
				First  = $a1;
				Second = $a2;
				Third  = $a3;
				Node   = $target
			}
			New-Object psobject -Property $Properties
			#Remediation line by line result
			$result = "H " + $n + " | N " + $target + "|" + $a1 + "|" + $a2 + "|" + $a3
		[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
		}
	}
}
catch
{
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}

#EOF
