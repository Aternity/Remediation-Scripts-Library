try{
    # Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

    #write-output $ARGS
    # Defining Arguments to be passed into variables to execute actions
    $BROWSER_NAME = $ARGS[0]
    #$OS_NAME = $ARGS[1] - OS checks are being done for IE only - rest of the browsers have the same location for cache. 

    #Setting Global Result Varaible
    $result = ""

    function ClearCache {
            Param ([string]$Cache_Path, [string]$BROWSER_NAME)

			# Initialize output
			$global:result += "`n----- INITIAL STATE -----`nUser default cache folder: $Cache_Path `n"

			$UserCacheFolderExists = (Test-Path $Cache_Path)
			$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $Cache_Path -ErrorAction SilentlyContinue))
			if ( $IsCacheEmpty ) 
			{
				$global:result += "Cache is empty, nothing to do"
			}
			else
			{
				try{
					$global:result += "Trying to delete files in the cache`n"
					Remove-Item $Cache_Path\* -Force -Recurse -ErrorAction Stop
				}
				catch
				{
					$IsFFRunning = (Get-Process -Name $BROWSER_NAME -ErrorAction SilentlyContinue)
					if ($IsFFRunning)
					{ 
						$global:result += "$BROWSER_NAME is running. Trying to stop gracefully`n"
						Get-Process $BROWSER_NAME -ErrorAction SilentlyContinue | % { if ($_.CloseMainWindow()) { Start-Sleep -Seconds 1 }}
					}
					$IsFFRunning = (Get-Process -Name $BROWSER_NAME -ErrorAction SilentlyContinue)
					if ($IsFFRunning) 
					{ 
						$global:result += "$BROWSER_NAME is still running. Stopping remaining instances`n"
						Get-Process -Name $BROWSER_NAME -ErrorAction SilentlyContinue | Kill -Force -ErrorAction SilentlyContinue
						Start-Sleep -Seconds 1 
					}
					$global:result += "Deleting remaining files in the cache`n"
					Remove-Item $Cache_Path\* -Force -Recurse -ErrorAction SilentlyContinue
				}

				#check
				$IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $Cache_Path -ErrorAction SilentlyContinue))
				if (!$IsCacheEmpty) { throw "Could not empty cache`n"+$global:result }

				#output
				$global:result += "`n----- END STATE -----`nUser default cache folder: $Cache_Path `nCache is empty"            
			} 
        }
		
        switch($BROWSER_NAME){
            "IE" {
                $result += "`n----- INITIAL STATE -----`nChecking for OS and determining Cache location `n"

                # Check for OS version first
                $OS_Name = (Get-WmiObject Win32_OperatingSystem).caption

                #Check which os endpoint is running and then set the cache path accordingly.
                if ( $OS_Name -like "Microsoft Windows 10*" -or $OS_Name -like "Microsoft Windows 8*" )
                {
                    $IE_Cache_Path = "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
                } 
                elseif ($OS_Name -like "Microsoft Windows 7*")
                {
                    $IE_Cache_Path = "$env:LOCALAPPDATA\Local\Microsoft\Windows\Temporary Internet Files"
                }

                ClearCache -Cache_Path $IE_Cache_Path -BROWSER_NAME $BROWSER_NAME
                break;
            }
            "Firefox" {
                $FF_Cache_Path = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*.default\cache2"
                ClearCache -Cache_Path $FF_Cache_Path -BROWSER_NAME $BROWSER_NAME 
                break
            }
            "Chrome" {
                $Chrome_Cache_Path = "$env:LOCALAPPDATA\Google\Chrome\USERDA~1\Default\Cache"
                ClearCache -Cache_Path $Chrome_Cache_Path -BROWSER_NAME $BROWSER_NAME
                break;
            }
            "EdgeLegacy" {
                $EDGE_Cache_Path = "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC" 
                ClearCache -Cache_Path $EDGE_Cache_Path -BROWSER_NAME $BROWSER_NAME
                break;
            }
            "EdgeChromium" {
                $EC_Cache_Path = "$env:LOCALAPPDATA\Microsoft\Edge\USERDA~1\Default\Cache"
                ClearCache -Cache_Path $EC_Cache_Path -BROWSER_NAME $BROWSER_NAME
                break;
            }
        }

        # Set Output message
        [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($global:result)    

}catch{
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}