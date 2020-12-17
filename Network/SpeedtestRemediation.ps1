
<#
.Synopsis
	Aternity - Remediation Script: SpeedTestRemediation
.DESCRIPTION
	Execute a speedtest test with speedtest.exe
	Provides Speed , latency , packet loss and jitter with public IP address, ISP and speedtest server
	
	References:
	* https://www.aternity.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
	Deploy in Aternity (Configuration > Remediation > Add Action) 
	Action Name: Speedtest
	Description: Launch a speedtest with a speficic server if needed
	Run the script in the System account: checked
	Parameter : ServerID If no server id is specified , it will take the first server
	Example : 8856

.VERSION
Date : 12/30/2002 V1.0	: First script
Date : 12/03/2020 V1.1  : Server ID added
V1.2 : Script Cleaning

.DATE
Date : 12/11/2020
#>

#Thresholds

#how much % packetloss until we alert.
$maxpacketloss = 2  
#What is the minimum expected download speed in Mbit/ps
$MinimumDownloadSpeed = 100 
#What is the minimum expected upload speed in Mbit/ps
$MinimumUploadSpeed = 20 
#ServerID
$ServerID =""
 
#Paramters
$ServerID = $args[0]
 
#Replace the Download URL to where you've uploaded the ZIP file yourself. We will only download this file once. 
#Latest version can be found at: https://www.speedtest.net/nl/apps/cli
$DownloadURL = "https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-win64.zip"
$DownloadLocation = "$($Env:ProgramData)\SpeedtestCLI"

try {
# Load Agent Module
	Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
	try {
		$TestDownloadLocation = Test-Path $DownloadLocation
		if (!$TestDownloadLocation) {
			new-item $DownloadLocation -ItemType Directory -force
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
			Invoke-WebRequest -Uri $DownloadURL -OutFile "$($DownloadLocation)\speedtest.zip"
			Expand-Archive "$($DownloadLocation)\speedtest.zip" -DestinationPath $DownloadLocation -Force
		} 
	}
	catch { 
		[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)	
		#write-host "The download and extraction of SpeedtestCLI failed. Error: $($_.Exception.Message)"
		exit 1
	}

	$PreviousResults = if (test-path "$($DownloadLocation)\LastResults.txt") { get-content "$($DownloadLocation)\LastResults.txt" | ConvertFrom-Json }
	If ($ServerID -ne "")
		{
		$SpeedtestResults = & "$($DownloadLocation)\speedtest.exe" --server-id=$ServerID --format=json --accept-license --accept-gdpr
		}
	else
		{
		$SpeedtestResults = & "$($DownloadLocation)\speedtest.exe" --format=json --accept-license --accept-gdpr
		}
	$SpeedtestResults | Out-File "$($DownloadLocation)\LastResults.txt" -Force
	$SpeedtestResults = $SpeedtestResults | ConvertFrom-Json
 
	#creating object
	[PSCustomObject]$SpeedtestObj = @{
		downloadspeed = [math]::Round($SpeedtestResults.download.bandwidth / 1000000 * 8, 2)
		uploadspeed   = [math]::Round($SpeedtestResults.upload.bandwidth / 1000000 * 8, 2)
		packetloss    = [math]::Round($SpeedtestResults.packetLoss)
		isp           = $SpeedtestResults.isp
		ExternalIP    = $SpeedtestResults.interface.externalIp
		InternalIP    = $SpeedtestResults.interface.internalIp
		UsedServer    = $SpeedtestResults.server.host
		ResultsURL    = $SpeedtestResults.result.url
		Jitter        = [math]::Round($SpeedtestResults.ping.jitter)
		Latency       = [math]::Round($SpeedtestResults.ping.latency)
	}
	$SpeedtestHealth = @()
	#Comparing against previous result. Alerting is download or upload differs more than 20%.
	if ($PreviousResults) {
		if ($PreviousResults.download.bandwidth / $SpeedtestResults.download.bandwidth * 100 -le 80) { $SpeedtestHealth += "Download speed difference is more than 20%" }
		if ($PreviousResults.upload.bandwidth / $SpeedtestResults.upload.bandwidth * 100 -le 80) { $SpeedtestHealth += "Upload speed difference is more than 20%" }
	}

	#Comparing against preset variables.
	if ($SpeedtestObj.downloadspeed -lt $MinimumDownloadSpeed) { $SpeedtestHealth += "`nDownload speed is lower than $MinimumDownloadSpeed Mbit/ps" }
	if ($SpeedtestObj.uploadspeed -lt $MinimumUploadSpeed) { $SpeedtestHealth += "`nUpload speed is lower than $MinimumUploadSpeed Mbit/ps`n" }
	if ($SpeedtestObj.packetloss -gt $MaxPacketLoss) { $SpeedtestHealth += "`nPacketloss is higher than $maxpacketloss%`n" }

	#result
	$result = "DL : "+ $SpeedtestObj.downloadspeed + "Mb/s | UL : " + $SpeedtestObj.uploadspeed + "Mb/s | PktLoss : "+ $SpeedtestObj.packetloss +  " | Jitter : "+ $SpeedtestObj.Jitter + " | Latency : " + $SpeedtestObj.Latency + " ms`n"
	$result += "ISP : " + $SpeedtestObj.isp + " | Ex IP : " + $SpeedtestObj.ExternalIP +  " | Int IP : " + $SpeedtestObj.InternalIP + " | Used Server : "+ $SpeedtestObj.UsedServer
	$result += "`n" + $SpeedtestHealth
	write-host $result
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
#EOF