# shortcut_check
author: @b00010111<br>
powershell script searches a given path or file and determines if .lnk files with remote IconLocation are present and print them to std out.<br>
EXPERIMENTAL: checks whether the host has the registry configured to allow or disallow remote Icon locations<br>
Errors will we written to  .shortcut_check.ps1_error.txt in current working directory.<br>
If you rename the script errors will be written to ".$NEWSCRIPTNAME_error.txt".<br>
If no options are given help is shown.<br>
Inspired by https://www.us-cert.gov/ncas/alerts/TA18-074A and the usage of remote IconLocation within windows shortcut files.<br>


Options:
* -p (-path) # to specify a path 
* -f (-file) # for a specific .lnk file
* -v (-verbose) y # if you want to see all found IconLocations
* EXPERIMENTAL feature!!!! -r (-registry) y  #specify -r y to check registry if remote IconLocation is allowed or not. EXPERIMENTAL feature!!!!

usage examples:
* .\shortcut_check.ps1 -p C:\ -r y -v y
* .\shortcut_check.ps1 -p C:\
* .\shortcut_check.ps1 -f C:\Users\exampleUser\Desktop\test_links\TEST.lnk -v y -r y
* .\shortcut_check.ps1 -f C:\Users\exampleUser\Desktop\test_links\TEST.lnk

## further work
If you are aware of ways to set a remote IconLocation within a shortcut file that are not find by the script and cause an SMB request please contact me on twitter.<br>
If you know more about how to disable remote IconLocations for the different Windows version please contact me on twitter.
