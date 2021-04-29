c:\windows\system32

<#
.Synopsis
   Aternity - Rebuild Corrupted Windows Perf Counters.
.DESCRIPTION
	When WMI queries are failing suggesting InvalidObjects - its necessary to solve the issue in order to avoid CPU Spikes caused on devices by WMI queries.
.REFERENCE
   https://docs.microsoft.com/en-us/troubleshoot/windows-server/performance/manually-rebuild-performance-counters
#>
try
{
    # Set new environment for Action Extensions Methods 
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
    
    #Rebuild WMI Perf Counter
    $rbwmicntr = New-object System.Diagnostics.ProcessStartInfo
    $rbwmicntr.CreateNoWindow = $true
    $rbwmicntr.UseShellExecute = $false
    $rbwmicntr.RedirectStandardOutput = $true
    $rbwmicntr.RedirectStandardError = $true
    $rbwmicntr.FileName = 'c:\windows\system32\lodctr.exe'
    $rbwmicntr.Arguments = @("/R")
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $rbwmicntr
    $process.Start() | Out-Null
    $process.WaitForExit()
    $output = $process.StandardOutput.ReadToEnd()
    $output
        
    #Resynch Performance Counter with WMI
    cd "C:\Windows\SysWOW64"
    WinMgmt.exe /resyncperf

    #Restart the Performance Logs and Alerts service
    Restart-Service -Name pla -Force

    #Restart WMI services
    Restart-Service -Name winmgmt -Force
    
    # Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($output)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
