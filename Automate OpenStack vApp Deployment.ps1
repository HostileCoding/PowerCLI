#Variable declaration  
$vCenterIPorFQDN="192.168.243.40"
$vCenterPort="443"  
$vCenterUsername="Administrator@vsphere.local"  
$vCenterPassword="vmware"  
$DatacenterFolder="DCFolder"  
$DatacenterName="Datacenter"  
$MgmtClusterName="MgmtCluster"
$OpenStackClusterNames=@("OpenStackCluster") #Cluster(s) managed by OpenStack
$MgmtHosts= @("192.168.243.144") #IP or FQDN of hosts participating in Management Cluster
$OpenStackHosts= @("192.168.243.143") #IP or FQDN of hosts participating in OpenStack Cluster
$HostUsername="root" #This assumes every host in both clusters have same user/password
$HostPassword="mypassword"  
$vSwitchName="vSwitch1" #vSwitch on which create br100 PortGroup
$vSwitchNics= @("vmnic1") #Nics that will be associated to vSwitch1
$portGroupName="br100" #PortGroup br100 used by OpenStack deployed VMs
$vlanId=100 #VLAN ID of br100 PortGroup
$SourceFilePath="C:\Users\Paolo\Downloads\VOVA_HAVANA.ova" #Path to VOVA file
$InstallDatastore="DS_VOVA" #Datastore on which VOVA will be placed
$DiskFormat="Thin" #Provisioning format: Thin | Thick | EagerZeroedThick
$DatastoreRegex= @("Shared_Datastore") #Datastores used by OpenStack Instances. Regex are applicable
$IPGateway="192.168.243.2"
$IPDns="192.168.243.2"
$IPappVOVA="192.168.243.150"
$SubnetMaskappVOVA="255.255.255.0"


Write-Host "Connecting to vCenter" -foregroundcolor "magenta"   
Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword  
Write-Host "Creating Folder" -foregroundcolor "magenta"   
Get-Folder -NoRecursion | New-Folder -Name $DatacenterFolder  

#Create Datacenter
Write-Host "Creating Datacenter" -foregroundcolor "magenta"
New-Datacenter -Location $DatacenterFolder -Name $DatacenterName

#Create Management Cluster
Write-Host "Creating Management Cluster" -foregroundcolor "magenta"   
New-Cluster -Location (Get-Datacenter -Name $DatacenterName) -Name $MgmtClusterName -DRSEnabled:$true -DrsAutomationLevel FullyAutomated 
 
#Create Cluster managed by OpenStack
foreach ($element in $OpenStackClusterNames) {
Write-Host "Creating" $element "Cluster" -foregroundcolor "magenta"   
New-Cluster -Location (Get-Datacenter -Name $DatacenterName) -Name $element -DRSEnabled:$true -DrsAutomationLevel FullyAutomated
}

$i = 0 #Initialize loop variable 

foreach ($element in $MgmtHosts) {  
      Write-Host "Adding" $element "to Management Cluster" -foregroundcolor "magenta"   
      Add-VMHost $element -Location $MgmtClusterName -User $HostUsername -Password $HostPassword -RunAsync -force:$true   
      Write-Host "One minute sleep in order to register" $element "into Management cluster" -foregroundcolor "magenta"  
      Start-Sleep -s 60  
      Write-Host "Setting up networking on" $element "host" -foregroundcolor "magenta"  
      if ($i -le $MgmtHosts.Length) {  
        #Create vSwitch1 on Management hosts
		New-VirtualSwitch -VMHost (Get-VMHost $element) -Name $vSwitchName -Nic $vSwitchNics | New-VirtualPortGroup -Name $portGroupName -VLanId $vlanId  
      }       
      $i++  
 } 

$i = 0 #Purge loop variable 

foreach ($element in $OpenStackHosts) {  
      Write-Host "Adding" $element "to OpenStack Cluster" -foregroundcolor "magenta"   
      Add-VMHost $element -Location $OpenStackClusterNames[0] -User $HostUsername -Password $HostPassword -RunAsync -force:$true  #This will add all hosts to the first cluster. If more than one iterate trough clusters.   
      Write-Host "One minute sleep in order to register" $element "into OpenStack cluster" -foregroundcolor "magenta"  
      Start-Sleep -s 60  
      Write-Host "Setting up networking on" $element "host" -foregroundcolor "magenta"  
      if ($i -le $OpenStackHosts.Length) {  
        #Create vSwitch1 on OpenStack hosts
		New-VirtualSwitch -VMHost (Get-VMHost $element) -Name $vSwitchName -Nic $vSwitchNics | New-VirtualPortGroup -Name $portGroupName -VLanId $vlanId  
      }       
      $i++  
 }  

#Upload the vSphere OpenStack Virtual Appliance to the first host of the Management Cluster, DRS will do the best placement
Write-Host "Upload the vSphere OpenStack Virtual Appliance to" $MgmtHosts[0] -foregroundcolor "magenta"
Import-vApp -VMHost $MgmtHosts[0] -Source $SourceFilePath -Datastore $InstallDatastore -DiskStorageFormat $DiskFormat -Force:$true

$appVOVA = Get-VM "VOVA"  

#Assign second nic to br100 PG
Write-Host "Configuring networking on" $appVOVA -foregroundcolor "magenta"  
Set-NetworkAdapter -NetworkAdapter (Get-NetworkAdapter -VM $appVOVA | Where-Object Name -eq "Network adapter 2") -NetworkName $portGroupName -Confirm:$false

#Credits for vApp configuration code goes to Alan Renouf - http://www.virtu-al.net/2014/03/10/automating-deployment-log-insight-powercli/
$VirtualMachineConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$VirtualMachineConfigSpec.vAppConfig = New-Object VMware.Vim.VmConfigSpec
$VirtualMachineConfigSpec.vAppConfig.property = New-Object VMware.Vim.VAppPropertySpec[] (11) #Create an array of properties with these many elements

$VirtualMachineConfigSpec.vAppConfig.property[0] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[0].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[0].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[0].info.key = 0 #Unique key
$VirtualMachineConfigSpec.vAppConfig.property[0].info.value = $vCenterIPorFQDN #vCenter IP

$VirtualMachineConfigSpec.vAppConfig.property[1] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[1].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[1].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[1].info.key = 1
$VirtualMachineConfigSpec.vAppConfig.property[1].info.value = $vCenterPort #vCenter Port

$VirtualMachineConfigSpec.vAppConfig.property[2] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[2].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[2].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[2].info.key = 2
$VirtualMachineConfigSpec.vAppConfig.property[2].info.value = $vCenterUsername #vCenter Username

$VirtualMachineConfigSpec.vAppConfig.property[3] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[3].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[3].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[3].info.key = 3
$VirtualMachineConfigSpec.vAppConfig.property[3].info.value = $vCenterPassword #vCenter Password

$VirtualMachineConfigSpec.vAppConfig.property[4] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[4].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[4].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[4].info.key = 4
$VirtualMachineConfigSpec.vAppConfig.property[4].info.value = $DatacenterName #Datacenter Name

$VirtualMachineConfigSpec.vAppConfig.property[5] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[5].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[5].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[5].info.key = 5
$VirtualMachineConfigSpec.vAppConfig.property[5].info.value = $OpenStackClusterNames -join ', ' #Cluster(s) managed by OpenStack

$VirtualMachineConfigSpec.vAppConfig.property[6] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[6].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[6].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[6].info.key = 6
$VirtualMachineConfigSpec.vAppConfig.property[6].info.value = $DatastoreRegex -join ', ' #Datastore(s) managed by OpenStack

$VirtualMachineConfigSpec.vAppConfig.property[7] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[7].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[7].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[7].info.key = 7
$VirtualMachineConfigSpec.vAppConfig.property[7].info.value = $IPGateway #Default gateway

$VirtualMachineConfigSpec.vAppConfig.property[8] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[8].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[8].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[8].info.key = 8
$VirtualMachineConfigSpec.vAppConfig.property[8].info.value = $IPDns #DNS

$VirtualMachineConfigSpec.vAppConfig.property[9] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[9].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[9].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[9].info.key = 9
$VirtualMachineConfigSpec.vAppConfig.property[9].info.value = $IPappVOVA #Appliance IP address

$VirtualMachineConfigSpec.vAppConfig.property[10] = New-Object VMware.Vim.VAppPropertySpec
$VirtualMachineConfigSpec.vAppConfig.property[10].operation = "edit"
$VirtualMachineConfigSpec.vAppConfig.property[10].info = New-Object VMware.Vim.VAppPropertyInfo
$VirtualMachineConfigSpec.vAppConfig.property[10].info.key = 10
$VirtualMachineConfigSpec.vAppConfig.property[10].info.value = $SubnetMaskappVOVA #Appliance Netmask

$Reconfig = $appVOVA.ExtensionData

$Configtask = $Reconfig.ReconfigVM_Task($VirtualMachineConfigSpec) #Apply changes by calling vSPhere API method ReconfigVM_Task

#Poweron VOVA vApp
Get-VM -Name $appVOVA | Start-VM

#Wait some time until the vApp boots up then open the browser
Start-Sleep -s 180
Start-Process -FilePath "http://$IPappVOVA"