Function Backup-VMHost {

	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True)]
		[string[]]$VMHost,

		[Parameter(Mandatory=$True)]
		[string]$FilePath
	)

	foreach($host in $VMHost){

		Get-VMHostFirmware -VMHost $host -DestinationPath $FilePath -BackupConfiguration
		Write-Host "Host $($host) backup completed."  -foregroundcolor "magenta"  

	}
}

Function Restore-VMHost {

	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True)]
		[string[]]$VMHost,

		[Parameter(Mandatory=$True)]
		[string]$FilePath,

		[Parameter(Mandatory=$True)]
		[string]$HostUsername,

		[Parameter(Mandatory=$True)]
		[string]$HostPassword
	)


	foreach($host in $VMHost){

		Write-Host "$($host) is entering Maintenance Mode"  -foregroundcolor "magenta"  
		Set-VMHost -VMHost $host -State "Maintenance"

		#Assuming every ESXi host having same username & password
		Set-VMHostFirmware -VMHost $host -SourcePath "$($FilePath)\configBundle-$($host).tgz" -Restore -HostUser $HostUsername -HostPassword $HostPassword
		Write-Host "Host $($host) restore completed"  -foregroundcolor "magenta"  

	}

	#Adjust this wait time according to your environment
	Write-Host "Waiting 3 minutes in order to allow every ESXi host to reboot"  -foregroundcolor "magenta"
	Start-sleep -s 180 

	foreach($host in $VMHost){

		Write-Host "$($host) is exiting Maintenance Mode"  -foregroundcolor "magenta"  
		Set-VMHost -VMHost $host -State "Connected"

	}

}