<#
.Synopsis
	Aternity - Remediation Script: RemediationDNSResponseTime
.DESCRIPTION
	Restart Aternity agent Service (A180WD)
	Use case: Check DNS connection add speed
	Tested on Windows 10
	
	References:
	* https://www.aternity.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
	Deploy in Aternity (Configuration > Remediation > Add Action) 
	Action Name: DNSReponseTimeRemediation
	Description: Give a domain and a DNS server (option) to check DNS Time resolution and availability
	Run the script in the System account: checked
	If no parameters are given, the script will check google DNS server with aternity domain name with 10 tests
	parameters : DNSServer;DNSNameToResove;NbOfTest
	example : 8.8.8.8;www.aternity.com;10

.VERISON
	V1.1

.DATE
	Date : 12/10/2020 V1.0 : creation
	Date : 01/18/2021 V1.1 : Add a DNS clear cache to force a DNS request
#>

#Variables#
$dnsserver = "8.8.8.8"
$dnsName = "www.aternity.com"
$numberoftests = 10

#Paramters
	$arguments = $args[0].split(";")
		
		#Start or stop
		if (!($arguments[0].trim() -eq "")) 
			{
			[string] $dnsserver = $arguments[0].trim()
			}
		if (!($arguments[1].trim() -eq "")) 
			{
			[string] $dnsName = $arguments[1].trim()
			}
		if (!($arguments[2].trim() -eq "")) 
			{
			[int] $numberoftests = $arguments[2].trim()
			}

try
{
	# Load Agent Module
	Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

	# Initialisation
	$totalmeasurement = 0
	$i = 0

	#Test
		while ($i -ne $numberoftests)
		{
			# Add a clear cache in order to force a DNS request
			Clear-DnsClientCache
			$measurement = Measure-Command {Resolve-DnsName $dnsName -Server "$($dnsserver)" -Type A}
			$totalmeasurement += $measurement.TotalSeconds
			#write-host $dnsserver $dnsName $measurement.TotalSeconds
			$i += 1
		}

	# results
	$totalmeasurement = [math]::Round($totalmeasurement / $numberoftests,3)
	$result = "DNS Server: " + $dnsserver + " | Resoved Name: " + $dnsName + " | Response time: " + $totalmeasurement + " s"
	
	# Set Output message
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
	#write-host $result
}
catch
{
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
	exit 1
}
#EOF
