# Aternity Custom Remediation Script to Rebuild Perf Counters to fix Invalid Object errors with WMI queries.

## When WMI queries are failing suggesting InvalidObjects - its necessary to solve the issue in order to avoid CPU Spikes caused on devices by WMI queries.

## Reference : https://docs.microsoft.com/en-us/troubleshoot/windows-server/performance/manually-rebuild-performance-counters 

* Use this script while analysis suggests WMI queries are causing "InvalidOperationException" and corrosponding events suggests CPU Spikes.

* Script tries to load 32 bit as well as 64 bit counters using Backup INI files from OS. 
* Resynch the newly loaded perf counter with WMI.
* Once reaload is completed successfully, Performance and Alerts Logs services will restart along with WMI services. 