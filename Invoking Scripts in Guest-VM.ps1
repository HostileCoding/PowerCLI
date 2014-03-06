#Variable declaration
$vCenterIPorFQDN="10.0.1.210"
$vCenterUsername="Administrator@vsphere.local"
$vCenterPassword="vmware"
$ESXiHost="10.0.1.62"
$NumberOfVmToDeploy=2 #How many VM deploy from template
$OracleTemplate="OraTemplate"
$DestinationDatastore="datastore1"
$ESXiHostUsername="root" #ESXi Host username
$ESXiHostPassword="mypassword" #ESXi Host password
$GuestVmUsername="local\Administrator" #Guest VM username
$GuestVmPassword="MyGuestVmPassword"  #Guest VM password
$ScriptContent="C:\Users\Administrator\Desktop\database\setup.exe -silent -noconfig -responseFile C:\Users\Administrator\Desktop\install.rsp" #Command to run inside Guest VM

Write-Host "Connecting to vCenter" -foregroundcolor "magenta" 
 
Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword

1..$NumberOfVmToDeploy | Foreach {

Write-Host "Creating" OracleDB$_ "VM" -foregroundcolor "magenta"

New-VM -VMHost (Get-VMHost -Name $ESXiHost) -Name OracleDB$_ -Template $OracleTemplate -Datastore $DestinationDatastore | Start-VM

Write-Host "Waiting 90 seconds in order to finish VM poweron" -foregroundcolor "magenta" 

Start-Sleep -s 90

Write-Host "Calling setup.exe inside guest VM in order to  perform an Oracle Database silent install" -foregroundcolor "magenta" 

Invoke-VMScript -VM OracleDB$_ -HostUser $ESXiHostUsername -HostPassword $ESXiHostPassword -GuestUser $GuestVmUsername -GuestPassword $GuestVmPassword -ScriptType bat -ScriptText $ScriptContent

}