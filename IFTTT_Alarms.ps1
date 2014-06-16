#Variable declaration
$vCenterIPorFQDN="192.168.243.172"
$vCenterUsername="Administrator@vsphere.local"
$vCenterPassword="vmware"
$OutputFile="C:\Inetpub\wwwroot\mywebsite\feed.xml" #Where you want to place generated report
 
 
Remove-Item $OutputFile #Delete files from previous runs
 
Write-Host "Connecting to vCenter" -foregroundcolor "magenta"
Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword

$date = Get-Date -Format o

#Feed Header
$header=@"
<?xml version="1.0" encoding="utf-8"?>
 
<feed xmlns="http://www.w3.org/2005/Atom">
 
	<title>Triggered Alarms Feed</title>
	<subtitle>This feed contains all triggered alarms and warnings</subtitle>
	<link href="http://hostilecoding.blogspot.com" rel="self" />
	<link href="http://hostilecoding.blogspot.com/" />
	<updated>$($date)</updated>
"@

#Feed Footer
$footer=@"
</feed>
"@

$hosts = Get-VMHost | Get-View #Retrieve all hosts from vCenter
 
$HostList = $null #Prevent variable to get dirtied from previous runs  
 
foreach ($esxihost in $hosts){ 											#For each Host
	foreach($triggered in $esxihost.TriggeredAlarmState){ 				#For each triggered alarm of each host
		$arrayline={} | Select HostName, AlarmType, AlarmInformations 	#Initialize line
		$alarmDefinition = Get-View -Id $triggered.Alarm 				#Get info on Alarm
		$arrayline.HostName = $esxihost.Name 							#Get host which has this alarm triggered
		$arrayline.AlarmType = $triggered.OverallStatus 				#Get if this is a Warning or an Alert
		$arrayline.AlarmInformations = $alarmDefinition.Info.Name 		#Get infos about alarm
		$HostList += $arrayline 										#Add line to array
		$HostList = @($HostList) 										#Post-Declare this is an array
	}
}

$header | Out-File -Encoding "UTF8" -Filepath $OutputFile 				#Do not append, recreate blank file each time

$result | Out-File -Encoding "UTF8" -Filepath $OutputFile -append

foreach ($item in $HostList){

$body = @"
<entry>
	<title>$(if($($item.AlarmType -eq "red")){"Alarm:"}else{"Warning:"}) $($item.HostName)</title>
			<link href="http://hostilecoding.blogspot.com/" />
			<link rel="alternate" type="text/html" href="http://hostilecoding.blogspot.com/"/>
			<link rel="edit" href="http://hostilecoding.blogspot.com/"/>
	<updated>$($date)</updated>
	<summary>$(if($($item.AlarmType -eq "red")){"Alarm Triggered"}else{"Warning Triggered"}).</summary>
			<content type="xhtml">
			   <div xmlns="http://www.w3.org/1999/xhtml">
				  <p>$($item.AlarmInformations)</p>
			   </div>
			</content>
			<author>
				  <name>$($vCenterUsername)</name>
		   </author>
</entry>
"@

	$body | Out-File -Encoding "UTF8" -Filepath $OutputFile -append

}

$footer | Out-File -Encoding "UTF8" -Filepath $OutputFile -append

Write-Host "Disconnecting from vCenter" -foregroundcolor "magenta" 
Disconnect-VIServer -Server $vCenterIPorFQDN -Confirm:$false