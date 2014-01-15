################################
#                              #
# vSS Management with PowerCLI #
#                              #
################################

$virtualswitch = "vSwitch0" #vSwitch

$virtualswitchiscsi = "vSwitch1" #vSwitch for iSCSI

$esxihostip = "192.168.116.60" #ESXi host IP Address

$vmotionip = "192.168.170.61" #vMotion VMkernel IP Address

$subnetmask = "255.255.255.0" #VMKernel subnet mask

$mtu = "9000" #MTU Size (Jumbo Frames for iSCSI VMKernels)

$vmnic = @("vmnic0","vmnic1","vmnic2","vmnic3","vmnic4","vmnic5") #Array of ESXi host's vmnics

$iscsi_ip = @("10.10.10.1","10.10.10.2") #IP Address to assign to iSCSI VMKernels

$iscsitargetip = "10.10.10.3" #iSCSI Target IP Address


#Get VMHost
$vmhost = Get-VMHost -Name $esxihostip

#Get ESXCLI
$esxcli = Get-EsxCli

#Add vmnic1,vmnic2,vmnic3 to vSwitch0
Get-VirtualSwitch -VMHost $vmhost -Name $virtualswitch | Add-VirtualSwitchPhysicalNetworkAdapter -VMHostPhysicalNic (Get-VMHostNetworkAdapter -Physical -Name $vmnic[1],$vmnic[2],$vmnic[3]) -Confirm:$false

#Management Network: active vmnic0, standby vmnic1, unused vmnic2 vmnic3
Get-VirtualPortGroup -VMHost $vmhost -Name "Management Network" | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $vmnic[0] -MakeNicStandby $vmnic[1] -MakeNicUnused $vmnic[2],$vmnic[3]

#Create vMotion VMKernel
New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup vMotion -VirtualSwitch $virtualswitch -IP $vmotionip -SubnetMask $subnetmask -VMotionEnabled:$true

#vMotion VMKernel: active vmnic1, standby vmnic0, unused vmnic2 vmnic3
Get-VirtualPortGroup -VMHost $vmhost -Name vMotion | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $vmnic[1] -MakeNicStandby $vmnic[0] -MakeNicUnused $vmnic[2],$vmnic[3]

#Reject MAC Address Changes and Forged Transmits on VM Portgroup
#EsxCLI command synthax: network vswitch standard portgroup policy security set --allow-forged-transmits --allow-mac-change --allow-promiscuous --portgroup-name --use-vswitch
$esxcli.network.vswitch.standard.portgroup.policy.security.set($false, $false, $false, "VM Network", $false)

#Create ISCSI vSwitch
New-VirtualSwitch -VMHost $vmhost -Name $virtualswitchiscsi -Nic $vmnic[4],$vmnic[5] -Mtu $mtu

#Create ISCSI VMKernel
New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup ISCSI-1 -VirtualSwitch $virtualswitchiscsi -IP $iscsi_ip[0] -SubnetMask $subnetmask -Mtu $mtu
New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup ISCSI-2 -VirtualSwitch $virtualswitchiscsi -IP $iscsi_ip[1] -SubnetMask $subnetmask -Mtu $mtu

#Set ISCSI VMKernel
Get-VirtualPortGroup -VMHost $vmhost -Name ISCSI-1 | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $vmnic[4] -MakeNicUnused $vmnic[5]
Get-VirtualPortGroup -VMHost $vmhost -Name ISCSI-2 | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $vmnic[5] -MakeNicUnused $vmnic[4]

#Add iSCSI Software Adapter
Get-VMHostStorage -VMHost $vmhost | Set-VMHostStorage -SoftwareIScsiEnabled:$true

#ISCSI PortBinding
$portname = Get-VMHostNetworkAdapter | where {$_.PortGroupName -match "ISCSI-*"} | %{$_.DeviceName}

$vmhba = Get-VMHostHba -VMHost $vmhost -Type iscsi | %{$_.Device}

$esxcli.iscsi.networkportal.add($vmhba, $false, $portname[0]) #Bind vmk2
$esxcli.iscsi.networkportal.add($vmhba, $false, $portname[1]) #Bind vmk3

#ISCSI Target Dynamic Discovery
New-IScsiHbaTarget -IScsiHba $vmhba -Address $iscsitargetip

#Rescan VMFS & HBAs
$vmhost | Get-VMHostStorage -RescanVmfs -RescanAllHba