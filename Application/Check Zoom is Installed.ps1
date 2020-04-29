try
{
        # Set new environment for Action Extensions Methods 
        Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

        # Check If Zoom is installed
        $Check=Test-Path "$($env:USERPROFILE)\AppData\Roaming\Zoom"
        #$Check

        #evaluate Check 
            if($Check -eq $false)  
            {
                [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 6","Not Installed")

            }
            else
            {
                [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 6","Installed")
            }

}
Catch
{
 [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}