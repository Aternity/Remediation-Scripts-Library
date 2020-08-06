<#
.Synopsis
   Aternity - Remediation Script: Remediation-Chrome-IE-Firefox-Edge-ClearUserCache
.DESCRIPTION
	Clear Cache from 5 different browsers by using arguments. Try to delete files from the cache folder and if any deletion fails then try to close browser forcefuly and retry to delete file in the cache folder.
    Use case: Fix browsing & login errors cache issue
	Tested on Windows 10, Chrome 77, Firefox 76.0.1, IE 11, Edge Legacy & Edge Chromium. 
	
	References:
	* https://www.aternity.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation
.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: All Browser Clear UserCache
   Description: Clear Browser user default cache folder
   Run the script in the System account: unchecked (must run in the current user context)
   Message From: IT Service Desk
   Header: Browser needs cleanup (clear cache)
   Question: Please close all browser windows and click OK when ready to proceed
#>
try
	{
		# Load Agent Module
		Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
		#write-output $ARGS
		# Defining Arguments to be passed into variables to execute actions
		$BROWSER_NAME = $ARGS[0]
		$OS_NAME = $ARGS[1]
		
		if ( $BROWSER_NAME -eq "Firefox" )
		{
			try
			{
				# variables
				$FF_Cache_Path = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*.default\cache2"

				# Initialize output
				$result = "`n----- INITIAL STATE -----`nUser default cache folder: $FF_Cache_Path `n"

				$UserCacheFolderExists = (Test-Path $FF_Cache_Path)
				$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $FF_Cache_Path -ErrorAction SilentlyContinue))
				if ( $IsCacheEmpty ) 
				{
					$result += "Cache is empty, nothing to do"
				}
				else
				{
					try
					{
					   $result += "Trying to delete files in the cache`n"
					   Remove-Item $FF_Cache_Path\* -Force -Recurse -ErrorAction Stop
					}
					catch
					{
						$IsFFRunning = (Get-Process -Name firefox -ErrorAction SilentlyContinue)
						if ($IsFFRunning)
						{ 
							$result += "Firefox is running. Trying to stop gracefully`n"
							Get-Process firefox -ErrorAction SilentlyContinue | % { if ($_.CloseMainWindow()) { Start-Sleep -Seconds 1 }}
						}
						$IsFFRunning = (Get-Process -Name firefox -ErrorAction SilentlyContinue)
						if ($IsFFRunning) 
						{ 
							$result += "Firefox is still running. Stopping remaining instances`n"
							Get-Process -Name firefox -ErrorAction SilentlyContinue | Kill -Force -ErrorAction SilentlyContinue
							Start-Sleep -Seconds 1 
						}
						$result += "Deleting remaining files in the cache`n"
						Remove-Item $FF_Cache_Path\* -Force -Recurse -ErrorAction SilentlyContinue
					}
					#check
					$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $FF_Cache_Path -ErrorAction SilentlyContinue))
					if (!$IsCacheEmpty) { throw "Could not empty cache`n"+$result }
					output
					$result += "`n----- END STATE -----`nUser default cache folder: $FF_Cache_Path `nCache is empty"            
				}
			# Set Output message
			[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
		}
		catch
			{
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
			}
		}
		elseif ( $BROWSER_NAME -eq "Chrome" )
		{
			try
			{
				# variables
				$Chrome_Cache_Path = "$env:LOCALAPPDATA\Google\Chrome\USERDA~1\Default\Cache"
				#Initialize output
				$result = "`n----- INITIAL STATE -----`nUser default cache folder: $Chrome_Cache_Path `n"
				$UserCacheFolderExists = (Test-Path $Chrome_Cache_Path)
				$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $Chrome_Cache_Path -ErrorAction SilentlyContinue))
				if ( $IsCacheEmpty ) 
				{
					$result += "Cache is empty, nothing to do"
				} 
				else 
				{           
					try 
					{
						$result += "Trying to delete files in the cache`n"
						Remove-Item $Chrome_Cache_Path\* -Force -Recurse -ErrorAction Stop
					} 
					catch
					{
						$IsChromeRunning = (Get-Process -Name Chrome -ErrorAction SilentlyContinue)
						if ($IsChromeRunning) 
						{ 
							$result += "Chrome is running. Trying to stop gracefully`n"
							Get-Process Chrome -ErrorAction SilentlyContinue | % { if ($_.CloseMainWindow()) { Start-Sleep -Seconds 1 }}
						}
						$IsChromeRunning = (Get-Process -Name Chrome -ErrorAction SilentlyContinue)
						if ($IsChromeRunning) 
						{ 
							$result += "Chrome is still running. Stopping remaining instances`n"
							Get-Process -Name Chrome -ErrorAction SilentlyContinue | Kill -Force -ErrorAction SilentlyContinue
							Start-Sleep -Seconds 1 
						}
						$result += "Deleting remaining files in the cache`n"
						Remove-Item $Chrome_Cache_Path\* -Force -Recurse -ErrorAction SilentlyContinue
					}
					#check
					$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $Chrome_Cache_Path -ErrorAction SilentlyContinue))
					if (!$IsCacheEmpty) { throw "Could not empty cache`n"+$result }
					#output
					$result += "`n----- END STATE -----`nUser default cache folder: $Chrome_Cache_Path `nCache is empty"            
				}
				# Set Output message
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
			}
			catch
			{
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
			}
		}
		elseif ( $BROWSER_NAME -eq "IE" )
		{
			try
			{
				$result = "`n----- INITIAL STATE -----`nChecking for OS and determining Cache location `n"
				# Check for OS version first
				$OS_Name = (Get-WmiObject Win32_OperatingSystem).caption
				#Check which os endpoint is running and then set the cache path accordingly.
				if ( $OS_Name -like "Microsoft Windows 10*" -or $OS_Name -like "Microsoft Windows 8*" )
				{
					$IE_Cache_Path = "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
					#Write-Output ($IE_Cache_Path)
				} 
				elseif ($OS_Name -like "Microsoft Windows 7*")
				{
					$IE_Cache_Path = "$env:LOCALAPPDATA\Local\Microsoft\Windows\Temporary Internet Files"
				}
				# Initialize output
				$result = "`User default cache folder: $IE_Cache_Path `n"
				$UserCacheFolderExists = (Test-Path $IE_Cache_Path)
				$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $IE_Cache_Path -ErrorAction SilentlyContinue))
				if ( $IsCacheEmpty ) 
				{
					$result += "Cache is empty, nothing to do"
				} 
				else 
				{           
					try
					{
					   $result += "Trying to delete files in the cache`n"
					   Remove-Item $IE_Cache_Path\* -Force -Recurse -ErrorAction Stop
					}
					catch
					{
						$IsIERunning = (Get-Process -Name iexplore -ErrorAction SilentlyContinue)
						if ($IsIERunning)
						{ 
							$result += "Internet Explore is running. Trying to stop gracefully`n"
							Get-Process iexplore -ErrorAction SilentlyContinue | % { if ($_.CloseMainWindow()) { Start-Sleep -Seconds 1 }}
						}
						$IsIERunning = (Get-Process -Name iexplore -ErrorAction SilentlyContinue)
						if ($IsIERunning) 
						{ 
							$result += "Internet Explore is still running. Stopping remaining instances`n"
							Get-Process -Name iexplore -ErrorAction SilentlyContinue | Kill -Force -ErrorAction SilentlyContinue
							Start-Sleep -Seconds 1 
						}
						$result += "Deleting remaining files in the cache`n"
						Remove-Item $IE_Cache_Path\* -Force -Recurse -ErrorAction SilentlyContinue
					}
					#check
					$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $IE_Cache_Path -ErrorAction SilentlyContinue))
					if (!$IsCacheEmpty) { throw "Could not empty cache`n"+$result }
					#output
					$result += "`n----- END STATE -----`nUser default cache folder: $IE_Cache_Path `nCache is empty"            
				}
				# Set Output message
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
			}
			catch
			{
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
			}

		}
		elseif ( $BROWSER_NAME -eq "EdgeLegacy" )
		{
			try
			{
			    # variables
				$EDGE_Cache_Path = "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC" 

				#Initialize output
				$result = "`n----- INITIAL STATE -----`nUser default cache folder: $EDGE_Cache_Path `n"

				$UserCacheFolderExists = (Test-Path $EDGE_Cache_Path)
				$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $EDGE_Cache_Path -ErrorAction SilentlyContinue))
			   
				if ( $IsCacheEmpty ) 
				{
					$result += "Cache is empty, nothing to do"
				} 
				else 
				{           
					try 
					{
						$result += "Trying to delete files in the cache`n"
						Remove-Item $EDGE_Cache_Path\* -Force -Recurse -ErrorAction Stop
					}
					catch 
					{
						$IsEDGERunning = (Get-Process -Name MicrosoftEdge -ErrorAction SilentlyContinue)
						if ($IsEDGERunning) 
						{ 
							$result += "EDGE is running. Trying to stop gracefully`n"
							Get-Process MicrosoftEdge -ErrorAction SilentlyContinue | % { if ($_.CloseMainWindow()) { Start-Sleep -Seconds 1 }}
						}
						$IsEDGERunning = (Get-Process -Name MicrosoftEdge -ErrorAction SilentlyContinue)
						if ($IsEDGERunning) 
						{ 
							$result += "EDGE is still running. Stopping remaining instances`n"
							Get-Process -Name MicrosoftEdge -ErrorAction SilentlyContinue | Kill -Force -ErrorAction SilentlyContinue
							Start-Sleep -Seconds 1 
						}
						$result += "Deleting remaining files in the cache`n"
						Remove-Item $EDGE_Cache_Path\* -Force -Recurse -ErrorAction SilentlyContinue
					}
					#check
					$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $EDGE_Cache_Path -ErrorAction SilentlyContinue))
					if (!$IsCacheEmpty) { throw "Could not empty cache`n"+$result }
					#output
					$result += "`n----- END STATE -----`nUser default cache folder: #EDGE_Cache_Path `nCache is empty"            
				}
				# Set Output message
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)		
			}
			catch
			{
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
			}
		}
		elseif ( $BROWSER_NAME -eq "EdgeChromium" )
		{
			try
			{
			    # variables
				$EC_Cache_Path = "$env:LOCALAPPDATA\Microsoft\Edge\USERDA~1\Default\Cache"

				#Initialize output
				$result = "`n----- INITIAL STATE -----`nUser default cache folder: $EC_Cache_Path `n"

				$UserCacheFolderExists = (Test-Path $EC_Cache_Path)
				$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $EC_Cache_Path -ErrorAction SilentlyContinue))
			   
				if ( $IsCacheEmpty ) 
				{
					$result += "Cache is empty, nothing to do"
				} 
				else 
				{           
					try
					{
						$result += "Trying to delete files in the cache`n"
						Remove-Item $EC_Cache_Path\* -Force -Recurse -ErrorAction Stop
					} 
					catch 
					{
						$IsECRunning = (Get-Process -Name msedge -ErrorAction SilentlyContinue)
						if ($IsECRunning) 
						{ 
							$result += "EDGE is running. Trying to stop gracefully`n"
							Get-Process msedge -ErrorAction SilentlyContinue | % { if ($_.CloseMainWindow()) { Start-Sleep -Seconds 1 }}
						}
						$IsECRunning = (Get-Process -Name msedge -ErrorAction SilentlyContinue)
						if ($IsECRunning) 
						{ 
							$result += "EDGE is still running. Stopping remaining instances`n"
							Get-Process -Name msedge -ErrorAction SilentlyContinue | Kill -Force -ErrorAction SilentlyContinue
							Start-Sleep -Seconds 1 
						}
						$result += "Deleting remaining files in the cache`n"
						Remove-Item $EC_Cache_Path\* -Force -Recurse -ErrorAction SilentlyContinue
					}
					#check
					$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $EC_Cache_Path -ErrorAction SilentlyContinue))
					if (!$IsCacheEmpty) { throw "Could not empty cache`n"+$result }
					#output
					$result += "`n----- END STATE -----`nUser default cache folder: #EC_Cache_Path `nCache is empty"            
				}
				# Set Output message
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
			}
			catch
			{
				[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
			}
		}
	}
catch
	{
		[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
	}

