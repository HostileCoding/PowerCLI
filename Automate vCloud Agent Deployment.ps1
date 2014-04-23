#Variable declaration
$vCenterIPorFQDN="192.168.243.172"
$vCenterUsername="Administrator@vsphere.local"
$vCenterPassword="vmware"
$pathToVcloudAgent="/opt/vmware/vcloud-director/agent" #Path of vCloud Agent in vCloud Director virtual machine
$FileVcloudAgent="vcloudagent-esx51-5.1.0-799577.zip" #vCloud Agent file that will be installed
$downloadDestination="C:\Users\Paolo\Desktop" #Where to download vCloud Agent on local machine
$vCdVmName="vCloud Director" #Name of vCloud Director virtual machine
$vCdVmUsername="root" #vCloud Director virtual machine username
$vCdVmPassword="vmware" #vCloud Director virtual machine password
$InstallHosts= @("192.168.243.144") #IP or FQDN of ESXi hosts on which vcloud agent will be installed
$HostUsername="root" #This assumes every host in both clusters have same user/password
$HostPassword="mypassword"
$puttyScpLocation='C:\Users\Paolo\Downloads\pscp.exe' #Location of pscp.exe (Putty Secure Copy) executable - Please preserve single quotes

Write-Host "Connecting to vCenter" -foregroundcolor "magenta" 
Connect-VIServer -Server $vCenterIPorFQDN -Username $vCenterUsername -Password $vCenterPassword

#Get new vCloud agent downloading it from the vCloud Director VM
Write-Host "Downloading" $FileVcloudAgent "to your local machine in" $downloadDestination "directory"  -foregroundcolor "magenta" 
Copy-VMGuestFile -Source "$($pathToVcloudAgent)/$($FileVcloudAgent)" -Destination $downloadDestination -VM $vCdVmName -GuestToLocal -GuestUser $vCdVmUsername -GuestPassword $vCdVmPassword

foreach ($element in $InstallHosts) { 

	#Set Host into Maintenance Mode
	Write-Host "Entering maintenance mode" -foregroundcolor "magenta" 
	Get-VMHost -Name $element | Set-VMHost -State Maintenance

	#Start SSH service on host in order to allow the copy of vcloud agent using Secure Copy
	Start-VMHostService -HostService (Get-VMHostService -VMHost $element | Where-Object Label -eq "SSH") -Confirm:$false

	#Check whether vcloud agent is installed or not
	$esx=Get-EsxCli -VMHost $element
	$isAlreadeyInstalled = $esx.software.vib.list($true) | Where-Object Name -like "vcloud-agent" | Select-Object Version

	if ($isAlreadeyInstalled.Version -eq $null) { #No previous agent on host.

		Write-Host "No vCloud agent found, proceeding to installation" -foregroundcolor "magenta"

	}else{ #Uninstall previous agent
		
		Write-Host "vCloud agent found. Let me uninstall it before proceeding" -foregroundcolor "magenta"
		$esx.software.vib.remove($false,$false,$true,$false,"vcloud-agent")

	}

	#Transfer vcloud agent over to ESXi host using Putty Secure Copy
	Write-Host "Copying vCloud agent over to ESXi host" -foregroundcolor "magenta"
	& $puttyScpLocation -pw $HostPassword "$($downloadDestination)\$($FileVcloudAgent)" "$($HostUsername)@$($element):/tmp"

	#Install vcloud agent
	Write-Host "Installing vCloud agent" -foregroundcolor "magenta"
	$esx.software.vib.install("/tmp/$($FileVcloudAgent)", $false, $false, $true, $false, $false)

	#Stop SSH service on host
	Stop-VMHostService -HostService (Get-VMHostService -VMHost $element | Where-Object Label -eq "SSH") -Confirm:$false

	#Exit Maintenance Mode
	Write-Host "Exiting maintenance mode" -foregroundcolor "magenta"
	Get-VMHost -Name $element | Set-VMHost -State Connected

}