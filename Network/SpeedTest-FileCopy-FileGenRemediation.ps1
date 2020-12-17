
<#
.Synopsis
   Aternity - Remediation Script: SpeedTest
.DESCRIPTION
	Execute a speedtest test in powershell 
    Provides Speed of the download and upload
	The script generates a file of the desired size and remove files when finnished
	References:
	* https://www.aternity.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
	Deploy in Aternity (Configuration > Remediation > Add Action) 
	Action Name: Speedtest-Dest-size
	Description: Launch a speedtest with a  xxx Bytes file
	Run the script in the System account: checked
	ARGUMENT:FileSize(MB);Destination_Path;FileName
	EXAMPLE:10;\\192.168.1.254\music\Temp;testfile.txt

.VERSION
 V1.0

.DATE
Date : 12/07/2020
#>

#Filesize in MB
$filesize=10

#URL to upload and download
$destPath = "\\192.168.1.254\music\Temp"

#FileName
$FileName = "testfile.txt"

#Download and upload location
$DownloadLocation = "$($Env:ProgramData)\SpeedtestAternity"

$arguments = $args[0].split(";")
	
	#Start or stop
	if (!($arguments[0].trim() -eq "")) 
		{
		[int] $filesize = $arguments[0].trim()
		}
	if (!($arguments[1].trim() -eq "")) 
		{
		[string] $destPath = $arguments[1].trim()
		}
	if (!($arguments[2].trim() -eq "")) 
		{
		[string] $FileName  = $arguments[2].trim()
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
		#write-host $DiskFreeSize
		# test file size and exit if not enough space. Add a 100MB protection
		if ( $disque.Name -Like "*C*")
			{
			if (($DiskFreeSize -lt ($filesize + 100)))
				{
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed("Not Enough space")
				#write-host "Not enough space"
				exit 1
				}
			else 
				{
				$result ="$($filesize) | $($destPath) | + $($FileName)" 
				
				$TestFile = $DownloadLocation + "\" + $FileName
				$TestFileExist = Test-Path $TestFile
					If ($TestFileExist)
						{
						remove-item $TestFile
						}
				$buffersize = $filesize*1024*1024
				$buffer = new-object byte[] $buffersize
				$RandomString= new-object Random
				$RandomString.NextBytes($buffer) 
				[IO.File]::WriteAllBytes($TestFile, $buffer) 
				}
			}
		else
			{
			write-host "No generation on " $disque.Name
			}
		}
	write-host "upload"
	#Launch the upload 
	$filetoupload = $DownloadLocation+ "\" +$FileName
	$UploadTimeRequestBefore = Get-Date -Format HH:mm:ss.fff
	Copy-Item -Path $filetoupload -Destination $destPath -Force
	$UploadTimeRequestAfter = Get-Date -Format HH:mm:ss.fff
	
	#Launch the download
	$filetodownload = $destPath + "\" +$FileName
	$DowloadTimeRequestbefore = Get-Date -Format HH:mm:ss.fff
	Copy-Item -Path $filetodownload -Destination $DownloadLocation -Force
	$DownloadTimeRequestAfter = Get-Date -Format HH:mm:ss.fff
	$FileToRemove = $destPath+ "\" +$FileName

	
	#results
	$UploadRequestTime = New-TimeSpan -Start $UploadTimeRequestBefore -End $UploadTimeRequestAfter
	$DownloadRequestTime = New-TimeSpan -Start $DowloadTimeRequestbefore -End $DownloadTimeRequestAfter
	$file = $DownloadLocation + "\" + $FileName
	$downloadedFile = Get-item $file
	$fileMB = ($downloadedFile.length)/1MB
	$UpSpeed = ((($downloadedFile.length)*8)/$UploadRequestTime.TotalSeconds)/1000/1000 
	$DownSpeed = ((($downloadedFile.length)*8)/$DownloadRequestTime.TotalSeconds)/1000/1000 
	$UpSpeed = [math]::Round($UpSpeed ,2)
	$DownSpeed = [math]::Round($DownSpeed ,2)
	$result =  "UL File MB : " + $fileMB + " | time : " + $UploadRequestTime.TotalSeconds  + " s | speed : " + $UpSpeed + " Mbps`n"
	$result +=  "DL File MB : " + $fileMB + " | time : " + $DownloadRequestTime.TotalSeconds  + " s | speed : " + $DownSpeed + " Mbps"
	
	#write-host $result
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
	
	#remove files
	remove-item $filetoupload 
	remove-item $filetodownload 

}	
catch { 
		#[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
		write-host $_.Exception.Message
		#exit 1
	}