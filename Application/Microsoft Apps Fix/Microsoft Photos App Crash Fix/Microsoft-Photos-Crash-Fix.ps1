Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

# Origianl RepairAppx.ps1 - by nicolas.dietrich@microsoft.com
# Microsoft Customer Support and Services Modern Apps troubleshooting tool
# This tool is provided AS IS, no support nor warranty of any kind is provided for its usage.
# https://github.com/CSS-Windows/WindowsDiag/tree/master/UEX/RepairAppx
# Updated by Trimming unnecessary functions to fix onmy Microsoft Photos crash reported in Windows and repairing using Aternity Solution. 

$VERSION = "v1.9"
$global:allUsersSwitch = "-AllUsers"
$global:userRights = $false
$global:trace = ""
$global:canInstallForAllUsers = $false

[Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager, Windows.ApplicationModel.Store.Preview.InstallControl, ContentType = WindowsRuntime] | Out-Null

function CheckAdminRights() {
    $isAdmin = $false

    try {
        $bytes = New-Object -TypeName byte[](4)
        $hToken = ([System.ServiceModel.PeerNode].Assembly.GetType('System.ServiceModel.Channels.AppContainerInfo')).GetMethod('GetCurrentProcessToken', $BindingFlags).Invoke($null, @())
        ([System.ServiceModel.PeerNode].Assembly.GetType('System.ServiceModel.Activation.Utility')).GetMethod('GetTokenInformation', $BindingFlags).Invoke($null, @($hToken, 18, [byte[]]$bytes))
        if ($bytes[0] -eq 1) {
            $GetTokenInformation.Invoke($null, @($hToken, 20, [byte[]]$bytes)) # TokenElevation
            if ($bytes[0]) { $global:userRights = "UAC disabled but token elevated (Build-in Admin)"; $isAdmin = $true }
            else { $global:userRights = "UAC is disabled and not elevated" }
        }
        if ($bytes[0] -eq 2) { $global:userRights = "UAC enabled and token elevated (Run As Admin)"; $isAdmin = $true }
        if ($bytes[0] -eq 3) { $global:userRights = "UAC enabled and token NOT elevated" }
    }
    catch {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            $global:userRights = "Administrator"
            $isAdmin = $true
        }
        else {
            $global:userRights = "NOT Administrator"
        }
    }

    try {
        $global:canInstallForAllUsers = $appInstallManager.CanInstallForAllUsers
    }
    catch {
        $global:canInstallForAllUsers = "N/A"
    }
    finally {
        if (($global:canInstallForAllUsers -ne $true) -and (!$isAdmin)) { $global:allUsersSwitch = "" }
    }
}

function RegisterPackageAndDeps() {
    $packages = Invoke-Expression "Get-AppXPackage $global:allUsersSwitch $package"

    $global:trace += "Force registering following packages:`r`n"
    $global:trace += "-------------------------------------`r`n"

    $packageCount = 0

    foreach ($p in $packages) {
        if ($no_deps) {
            $global:trace += "  - [No dependencies processing was requested]`r`n"
        }
        else {
            ForEach ($dependencies in (Get-AppxPackageManifest $p.PackageFullName).package.dependencies.packagedependency.name) {
                $dep = Invoke-Expression "Get-AppXPackage $global:allUsersSwitch -PackageTypeFilter Framework $dependencies"
                ForEach ($d in $dep) {
                    $global:trace += "  - " + $d.PackageFullName + "`r`n"
                    $manifestPath = Join-Path -Path $d.InstallLocation -ChildPath "AppxManifest.xml"
                    if (Test-Path($manifestPath)) {
                        # Masking errors especially for frequent "Deployment failed with HRESULT: 0x80073D06, The package could not be installed because a higher version of this package is already installed."
                        Add-AppxPackage -DisableDevelopmentMode -ForceApplicationShutdown -register  $manifestPath -ErrorAction SilentlyContinue
                        $packageCount ++
                    }
                    else {
                        $global:trace += "    -> Can't find Manifest to register: $manifestPath`r`n"
                    }
                }
            }
        }
        $manifestPath = Join-Path -Path $p.InstallLocation -ChildPath "AppxManifest.xml"
        if (Test-Path($manifestPath)) {
            Add-AppxPackage -DisableDevelopmentMode -ForceApplicationShutdown -register  $manifestPath
        }
        else {
            $global:trace += "    -> Can't find Manifest to register: $manifestPath`r`n"
        }
    }
    $global:trace += "`r`n"

    return $packageCount
}

try {

    $package = '*photo*'

    [switch]$no_deps = $false

    $trace += "RepairAppx $VERSION - Repair & troubleshooting tool for AppX packages`r`n"
    $trace += "This tool is provided AS IS, no support nor warranty of any kind is provided for its usage.`r`n"

    $trace += "Command line run: " + $MyInvocation.Line
    $trace += "`r`n"

    $appInstallManager = New-Object Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager

    CheckAdminRights

    $packageCount = RegisterPackageAndDeps

    if ($packageCount) {
        switch ($packageCount) {
            0 { $result = 'WARNING`tNo packages updated' }
            1 { $result = 'SUCCESS`t1 package updated' }
            default { $result = "SUCCESS`t$packageCount packages updated" }
        }
    }
    else {
        $result = "Attempt to register packages did not return cleanly."
    }

    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch {

    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)

}
