
<#
.Synopsis
   Aternity - Remediation Script: SpeedTest-WebClient-remediation
.DESCRIPTION
	Execute a speedtest test in powershell netclient
	Provides Speed of a web download 
		References:
	* https://www.aternity.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
	Deploy in Aternity (Configuration > Remediation > Add Action) 
	Action Name: Speedtest-Dest-size
	Description: Launch a speedtest with a  xxx Bytes file
	Run the script in the System account: checked
	Arguments : URL;File;DownloadLocaltion

.VERSION
V1.0 : creation
V1.1 : Script cleaning

.DATE
Date : 12/11/2020
#>


#URL to upload and download
$destURL = ""

#FileName
$FileName = "testfile.txt"

#Download and upload location
$DownloadLocation = "$($Env:ProgramData)\SpeedtestAternity"


$arguments = $args[0].split(";")
	
	#Start or stop
	if (!($arguments[0].trim() -eq "")) 
		{
		[string] $destURL = $arguments[0].trim()
		}
	if (!($arguments[1].trim() -eq "")) 
		{
		[string] $FileName = $arguments[1].trim()
		}
	if (!($arguments[2].trim() -eq "")) 
		{
		[string] $DownloadLocation  = $arguments[2].trim()
		}

try {
	# Load Agent Module
	Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

	#create working path and create file

		$TestDownloadLocation = Test-Path $DownloadLocation
		if (!$TestDownloadLocation) {
			new-item $DownloadLocation -ItemType Directory -force
		} 
		$elements = get-WmiObject Win32_LogicalDisk
		foreach($disque in $elements ) {

		# calul de la taille en Giga octet
		$DiskFreeSize = $disque.freespace / (1024*1024)
		write-host $DiskFreeSize
		# test file size and exit if not enough space. Add a 100MB protection
		if ( $disque.Name -Like "*C*")
			{
			if (($DiskFreeSize -lt ($filesize + 100)))
				{
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed("Not Enough space")
				write-host "Not enough space"
				exit 1
				}
			else 
				{
				write-host "Enough space for file "
				}
			}
		else
			{
			write-host "No generation on " + $disque.Name
			Exit 1
			}
		}

	#Launch the download
	$adresse = $destURL+$FileName
	$file = $DownloadLocation+"\"+$FileName
	$wc = New-Object net.webclient
	$TimeRequestbefore = Get-Date -Format HH:mm:ss.fff
	$wc.Downloadfile($adresse, $file)
	$TimeRequestAfter = Get-Date -Format HH:mm:ss.fff

	#results
	$RequestTime = New-TimeSpan -Start $TimeRequestbefore -End $TimeRequestafter
	$downloadedFile = Get-item $file
	$fileMB = ($downloadedFile.length)/1MB
	$Speed = ((($downloadedFile.length)*8)/$RequestTime.TotalSeconds)/1000/1000 
	$Speed = [math]::Round($Speed,2)
	$result =  "File: " + $fileMB + " MB | Time : " + $RequestTime.TotalSeconds  + " s| Speed : " + $Speed + " Mbps"

	[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)

	#remove file
	remove-item $file
}

	catch { 
		[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
		exit 1
	}
#EOF




