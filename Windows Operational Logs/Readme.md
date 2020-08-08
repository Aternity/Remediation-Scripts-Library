# Enable-DNS-Operational-Windows-Logs.ps1
Enabling Windows DNS Operations logs provide insights on queries that may be of an interest to diagnose issues from Endpoints. 
Disabling Windows DNS Operations logs on Endpoints. 
Follow the document from microsoft to see more details on which events are of an interest to then monitor using Health Events. 

https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/dn800669(v=ws.11)

## USAGE
`````
Enable
`````
Depending on the use case - this script can be used for Custom data or any other custom monitors. Easiet way is to create a remediation action in Aternity to enable DNS Operational Logs. 
`````
Disable DNS Event Logs
`````
Create another remediation action to disable the DNS event logs.
