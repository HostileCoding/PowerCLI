#Variable declaration
$vCenterIPorFQDN="10.0.1.210"
$vCenterUsername="Administrator@vsphere.local"
$vCenterPassword="vmware"
$ClusterName="My Cluster" #Name of the cluster from which you want to retrieve VM infos
#Location where you want to place generated JSON Files.
#Please be aware that you should place them in the "data" folder in order to make WebPowerCLI read data from them
$OutputPath="C:\Users\Paolo\Desktop\data" 

Write-Host "Depending on how many VMs you have in your cluster this script could take a while...please be patient" -foregroundcolor "magenta" 

Write-Host "Connecting to vCenter" -foregroundcolor "magenta" 
Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword

$vms = Get-Cluster -Name $ClusterName | Get-VM

$vms | ConvertTo-Json -Depth 1 > $OutputPath\vms_all.json

foreach($vm in $vms){

Write-Host "Generating JSON file for VM:" $vm -foregroundcolor "magenta" 

Get-VM -Name $vm | Select * -ExcludeProperty ExtensionData | ConvertTo-Json -Depth 1 > $OutputPath\$($vm.Id).json

}

Write-Host "Disconnecting from vCenter" -foregroundcolor "magenta" 
Disconnect-VIServer * -Confirm:$false