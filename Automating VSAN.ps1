#Registering VSAN PowerCLI module
$p = [Environment]::GetEnvironmentVariable("PSModulePath")  
echo $p #Show your current path to modules  
$p += ";C:\Users\Paolo\WindowsPowerShell\Modules" #Add your custom location for modules  
[Environment]::SetEnvironmentVariable("PSModulePath",$p)

#Variable declaration
$vCenterIPorFQDN="192.168.243.40"
$vCenterUsername="Administrator@vsphere.local"
$vCenterPassword="vmware"
$DatacenterFolder="DCFolder"
$DatacenterName="VSANDC"
$ClusterName="NewCluster"
$VSANHosts= @("192.168.243.137","192.168.243.142","192.168.243.141") #IP or FQDN of hosts participating in VSAN cluster
$HostUsername="root"
$HostPassword="mypassword"
$vSwitchName="vSwitch0" #vSwitch on which create VSAN enabled vmkernel
$VSANvmkernelIP= @("10.24.45.1","10.24.45.2","10.24.45.3") #IP for VSAN enabled vmkernel
$VSANvmkernelSubnetMask="255.255.255.0" #Subnet Mask for VSAN enabled vmkernel
$vsanLicense="XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" #VSAN License code

Write-Host "Importing PowerCLI VSAN cmdlets" -foregroundcolor "magenta"  
Import-Module VMware.VimAutomation.Extensions

Write-Host "Connecting to vCenter" -foregroundcolor "magenta"  
Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword

Write-Host "Creating Folder" -foregroundcolor "magenta"  
Get-Folder -NoRecursion | New-Folder -Name $DatacenterFolder

Write-Host "Creating Datacenter and Cluster" -foregroundcolor "magenta"  

New-Cluster -Location (  
New-Datacenter -Location $DatacenterFolder -Name $DatacenterName  
) -Name $ClusterName -VsanEnabled:$true -VsanDiskClaimMode Automatic
 
$i = 0 #Initialize loop variable

Write-Host "Licensing VSAN cluster" -foregroundcolor "magenta"
#Credits to Mike Laverick - http://www.mikelaverick.com/2013/11/back-to-basics-post-configuration-of-vcenter-5-5-install-powercli/
$datacenterMoRef = (Get-Cluster -Name NewCluster | get-view).MoRef
$serviceinstance = Get-View ServiceInstance
$LicManRef=$serviceinstance.Content.LicenseManager
$LicManView=Get-View $LicManRef
$licenseassetmanager = Get-View $LicManView.LicenseAssignmentManager
$licenseassetmanager.UpdateAssignedLicense($datacenterMoRef.value,$vsanLicense,"Virtual SAN 5.5 Advanced")

foreach ($element in $VSANHosts) {

	Write-Host "Adding" $element "to Cluster" -foregroundcolor "magenta"  
	Add-VMHost $element -Location $ClusterName -User $HostUsername -Password $HostPassword -RunAsync -force:$true  
	
	Write-Host "One minute sleep in order to register" $element "into the cluster" -foregroundcolor "magenta"
	Start-Sleep -s 60
	
	Write-Host "Enabling VSAN vmkernel on" $element "host" -foregroundcolor "magenta"
	if ($i -le $VSANHosts.Length) {
	
		New-VMHostNetworkAdapter -VMHost (Get-VMHost -Name $element) -PortGroup VSAN -VirtualSwitch $vSwitchName -IP $VSANvmkernelIP[$i] -SubnetMask $VSANvmkernelSubnetMask -VsanTrafficEnabled:$true
	
	}	

	$i++
}