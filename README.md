# shortcut_check
powershell script searches a given path or file and determines if .lnk files with remote IconLocation are present and print them to std out.
EXPERIMENTAL: checks whether the host has the registry configured to allow or disallow remote Icon locations
Errors will we written to  .shortcut_check.ps1_error.txt in current working directory.
If you rename the script errors will be written to ".$NEWSCRIPTNAME_error.txt".
If no options are given help is shown.
Inspired by https://www.us-cert.gov/ncas/alerts/TA18-074A and the usage of remote IconLocation within windows shortcut files. 


Options:
-p (-path) # to specify a path 
-f (-file) # for a specific .lnk file
-v (-verbose) y # if you want to see all found IconLocations
EXPERIMENTAL feature!!!! -r (-registry) y  #specify -r y to check registry if remote IconLocation is allowed or not. EXPERIMENTAL feature!!!!

usage examples:
.\shortcut_check.ps1 -p C:\ -r y -v y
.\shortcut_check.ps1 -p C:\
.\shortcut_check.ps1 -f C:\Users\exampleUser\Desktop\test_links\TEST.lnk -v y -r y
.\shortcut_check.ps1 -f C:\Users\exampleUser\Desktop\test_links\TEST.lnk
