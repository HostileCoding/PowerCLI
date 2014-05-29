#Variable declaration
$vCenterIPorFQDN="192.168.243.172"
$vCenterUsername="Administrator@vsphere.local"
$vCenterPassword="vmware"
$destination = "C:\Users\Paolo\Desktop" #Location where to download support bundles

Write-Host "Connecting to vCenter" -foregroundcolor "magenta" 
Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword

$hosts = Get-VMHost #Retrieve all hosts from vCenter

Write-Host "Downloading vCenter support bundle" -foregroundcolor "magenta"
Get-Log -Bundle -DestinationPath $destination

foreach ($esxihost in $hosts){
	Write-Host "Downloading support bundle for ESXi host $($esxihost.Name)"  -foregroundcolor "magenta"
	Get-Log -VMHost (Get-VMHost -Name $esxihost.Name) -Bundle -DestinationPath $destination
}