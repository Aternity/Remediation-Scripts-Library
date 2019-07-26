# Remediation scripts

In this repo, you will be able to find examples of Remediation scripts shared by the Riverbed Community

Related links:

- Ask the community: https://community.riverbed.com
- Watch how to Improve Service Desk KPIs with SteelCentral Automated Remediation: https://www.youtube.com/watch?v=01GPFS21A9E
- Read the manual https://help.aternity.com/search?facetreset=yes&q=remediation
- Share ideas https://aternity.ideas.riverbed.com 
- Try Aternity http://riverbed.com/try-aternity

## How to contribute

The community website is currently the best place to start: https://community.riverbed.com.
There you can create questions, attach draft of script, discuss about it,... You can put the word "remediation" in the title or somewhere in your post to find easily.

And if you are already familair with github, please do not hesitate to submit pull requests. More details are coming on this topic.

## FAQ

### How to sign and test signed Remediation scripts

When you have a Remediation script ready (for example, Remediation-DNS-ClearCache.ps1) you have to sign it before configuring it in the Remediation action in Aternity. The User Device where it will be run must have Aternity agent installed and trust the certificate of the publisher, as the agent installer will by default set Action Policy Execution to Trusted.

Here is how to setup a quick test environment and sign new Remediation scripts. Depending on your environment you might need to set the powershell execution policy prior running the preparation scripts. For example, when launching PowerShell console, the following line would all to execute any script (.ps1 file) in the current PowerShell session:

```powershell
Set-ExecutionPolicy Unrestricted -Scope Process
```

#### Things to do once to set up a test environment

- Step 1: On the signing machine, where you will sign Remediation scripts, run once the script Prepare-RemediationSigning.ps1. It will generate a self-signed publisher certificate for code signing in the local certs store and export it as a certificate file (.cer). In the certs store, the certificate will have the subject "Aternity Remediation Code Signing".

```powershell
#On the signing machine
.\Prepare-RemediationSigning.ps1
```

Output example:

```output
    Directory: C:\Riverbed-Community-Toolkit\Aternity\Remediation


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         5/1/2019  12:02 PM            812 Aternity-Remediation-Certificate.cer
```

- Step 2: On the test user deivce where the Aternity agent is installed, copy the certificate file (.cer) and script Import-RemediationSigningCertificate.ps1 in a local directory. Then from this local directory execute the Powershell script with administrator privileges (i.e. launch Powershell with Run as Administrator). It will import the certificate into both Root CA and TrustedPublishers machine certs stores to establish the trust.

```powershell
#On the user test device
.\Import-RemediationSigningCertificate.ps1
```

#### Sign a new script

On the machine prepared for signing, the Powershell script Sign-RemediationScript.ps1 can sign Remediation scripts. It uses the certificate created previously in the local certs store. The Source parameter is the path of the script to sign and Destination is the path where the signed file will be created.

The signed script can then be uploaded in a Aternity remediation action and executed on a user test device.

Example:

```powershell
.\Sign-RemediationScript.ps1 -Source .\Network\Remediation-DNS-ClearCache.ps1 -Destination .\Signed\Remediation-DNS-ClearCache-signed.ps1
```

Output example:

```output
    Directory: C:\Riverbed-Community-Toolkit\Aternity\Remediation\Signed


SignerCertificate                         Status     Path
-----------------                         ------     ----
E2C88872665FE1B5B8430E53EC7213B1171241E3  Valid      Remediation-DNS-ClearCache-signed.ps1
```

#### Trigger the action in Aternity

Find the User test device (ex. type the device name in the Search bar), open the Device Events dashboard and run the Remediation (click Run Action button).

### Quick step-by-step to test Remediation

On the signing machine:

- step 1: [Download](https://github.com/riverbed/Riverbed-Community-Toolkit/archive/master.zip) the kit archive and extract all in C:\

- step 2: Launch PowerShell as Administrator to prepare signing cert and sign a script

```powershell
# Depending on the environment the following line is not required. It sets the execution policy to be able to execute .ps1 script
Set-ExecutionPolicy Unrestricted -Scope Process
#
Set-Location C:\Riverbed-Community-Toolkit-master\Aternity\Remediation
.\Prepare-RemediationSigning.ps1
New-Item -Type Directory Signed
.\Sign-RemediationScript.ps1 -Source .\Network\Remediation-DNS-ClearCache.ps1 -Destination .\Signed\Remediation-DNS-ClearCache-signed.ps1
```

- step 3: open Aternity, create a new remediation action for "DNS-ClearCache" and upload the signed script

On the user test device

- step 4: Create a folder C:\install and retrieve from the signing machine the certificate Aternity-Remediation-Certificate.cer and the script Import-RemediationSigningCertificate.ps1 into it

- step 5: Launch PowerShell as Administrator and import the cert

```powershell
# Depending on the environment the following line is not required. It sets the execution policy to be able to execute .ps1 scrip
Set-ExecutionPolicy Unrestricted -Scope Process
#
Set-Location c:\install
.\Import-RemediationSigningCertificate.ps1
```

- step 6: Install the Aternity agent (if not already done)

In Aternity,

- step 7: In the Remediation, open the menu for "DNS-ClearCache", click run and type the name of the user test device to apply the remediation

#### Fix signing issue

The execution of the script Sign-RemediationScript.ps1 might give this error:

```powershell
Set-AuthenticodeSignature : Cannot convert 'System.Object[]' to the type
'System.Security.Cryptography.X509Certificates.X509Certificate2' required by parameter 'Certificate'. Specified method
is not supported.
At C:\Riverbed-Community-Toolkit-master\Aternity\Remediation\Sign-RemediationScript.ps1:27 char:40
+ Set-AuthenticodeSignature -Certificate $cert -FilePath $Destination
+                                        ~~~~~
    + CategoryInfo          : InvalidArgument: (:) [Set-AuthenticodeSignature], ParameterBindingException
    + FullyQualifiedErrorId : CannotConvertArgument,Microsoft.PowerShell.Commands.SetAuthenticodeSignatureCommand
```

It happens if the script Prepare-RemediationSigning.ps1 has run multiple times and you have now many certificates with the same subject name. The last version of the script will now give a more explicit message:

```powershell
Sign-RemediationScript.ps1 : Cannot choose which certificate to use. Multiple certs found with the same subject: Aternity Remediation Code Signing.
Please remove extra certs, keep only one cert and retry.
You can delete all existing using .\Clean-RemediationSigning.ps1
At line:1 char:1
+ .\Sign-RemediationScript.ps1 -subject Aternity Remediation Code Signing
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Sign-RemediationScript.ps1
```

To fix, you can clean-up all certificates with the following, and retry the setup from the begining using Prepare-RemediationSigning.ps1, Sign-RemediationScript.ps1 and import new cert on the test devices.

```powershell
.\Clean-RemediationSigning.ps1
```

### Developing remediation scripts

#### Generic templates for remediation scripts

A first basic template is available, Aternity-Remediation-Template.ps1.
More advanced, for example with error handling, would be great to have.

#### How to return an error status in a remediation script

The SetFailed method returns a error status with the message in parameter.

```powershell
[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed("message")
```
