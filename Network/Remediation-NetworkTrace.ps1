<#
.Synopsis
   Aternity - Remediation Script: NetworkTrace
.DESCRIPTION
	This script will start and stop a Network Trace
	parameters : [Start|Stop];Folder;Trace;Buffer;Destination
	[Start|Stop] : Start or stop the trace
	Folder : Where the trace will be stored. If it doesn't exists , it will be created : Default c:\temp
	Trace : Name of the trace. Default : Trace.etl
	Buffer : Buffer size : Default 100 MB
	Destination : Network destination where the trace will be copied. If blank, it will be stored only localy

	References:
	* https://www.aternity.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
	This script start a packet capture on a device and store it in a c:\temp folder 
	Data are cached in a circular buffer of 100 MB and store in an Etl file.
	Session is not persistant.
	You need to launch the stop command with the associated script
	you need to use etl2pcapng to load data in wireshark You can download etl2pcapng from https://github.com/microsoft/etl2pcapng
	Parameters to start= Start;;;200MB;\\192.168.1.254\Disque dur\Trace
	Parameters to stop= Stop;;;200MB;\\192.168.1.254\Disque dur\Trace

.Version 1.1 date : 2021/03/19
	
	
#>
# Parameters
$Action = "Stop"
$FolderToCreate = "c:\temp"
$TraceFile="trace.etl"
$TraceSize = "100MB"
$FileMode = "circular"
$comment1 = "Trace started in"
$comment2 = "Trace stopped"
$comment3 = "file store localy"
$Destination = ""
$IPFilter =""
$result =""
#logic and script

try
{
	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
    #Add-Type -AssemblyName PresentationCore,PresentationFramework

	# Parse the arguments to get 
	# [Start|Stop],Folder,Trace,Buffer,Destination
	# 
	$arguments = $args[0].split(";")
	
	#Start or stop
		if (!($arguments[0].trim() -eq "")) 
		{
		[string] $Action = $arguments[0].trim()
		}
	#Folder	
	if (!($arguments[1].trim() -eq "")) 
		{
		[string] $FolderToCreate = $arguments[1].trim()
		}
	#Trace File	
	if (!($arguments[2].trim() -eq "")) 
		{
		[string] $TraceFile = $arguments[2].trim()
		}
	#Buffer Size	
	if (!($arguments[3].trim() -eq "")) 
		{
		[string] $TraceSize= $arguments[3].trim()
		}
	#Destination
	if (!($arguments[4].trim() -eq "")) 
		{
		[string] $Destination = $arguments[4].trim()
		}

    #region Remediation action logic
	If(!(Test-Path -path $FolderToCreate)) 
    { 
     #if it does not create it 
     New-Item -ItemType Directory -Force -Path "$($FolderToCreate)" 
    } 
	$FileToUse=$FolderToCreate+"\"+$TraceFile
	Write-host $FileToUse
	If($Action -eq "Start")
		{
		#Start network trace
		#$result = c:\windows\system32\netsh.exe trace start overwrite=yes capture=yes report=no maxsize="$($TraceSize)" filemode="$($FileMode)" tracefile="$($FileToUse)"
        if ([Environment]::Is64BitProcess) 
			{
			$result = netsh trace start overwrite=yes capture=yes report=no filemode=circular tracefile=c:\temp\trace.etl
			$result +="`n" + $comment1 + " a " + $TraceSize + " " + $FileMode  + "buffer stored in " +$FileToUse
			}
		else
			{
			$result = C:\Windows\Sysnative\netsh trace start overwrite=yes capture=yes report=no filemode=circular tracefile=c:\temp\trace.etl
			$result +="`n" + $comment1 + " a " + $TraceSize + " " + $FileMode  + "buffer stored in " +$FileToUse
			}
		}
	else
		{
		if ([Environment]::Is64BitProcess) 
			{
			#Stop network trace
			$result = netsh trace stop
			}
		else
			{
			#Stop network trace
			$result = C:\Windows\Sysnative\netsh trace stop
			}

		# Verify if destination path exists. If exists , copy trace
		If(Test-Path -path $Destination)
		{ 
			Copy-Item -Path $FileToUse -Destination $Destination -Force
			$result += $comment2 + " and copied in " + $Destination
			}
		else
			{
			$result = $comment3 
			}
         }
        
	#endregion
	# Set Output message
    Write-host $result
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    Write-host $_.Exception.Message
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
#EOF
