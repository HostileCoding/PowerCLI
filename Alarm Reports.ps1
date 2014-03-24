#Variable declaration
$vCenterIPorFQDN="10.0.1.210"
$vCenterUsername="Administrator@vsphere.local"
$vCenterPassword="vmware"
$OutputFile="C:\Users\Paolo\Desktop\Report.html" #Where you want to place generated report

Write-Host "Connecting to vCenter" -foregroundcolor "magenta" 
Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword

#A JavaScript to add some style to our report
$htmlheader = @"
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
<script type="text/javascript">
`$(document).ready(function(){
    `$( "td:contains('yellow')" ).css('background-color', '#FDF099'); //If yellow alarm triggered set cell background color to yellow
	`$( "td:contains('yellow')" ).text('Warning'); //Replace text 'yellow' with 'Warning'
	`$( "td:contains('red')" ).css('background-color', '#FCC' ); //If yellow alarm triggered set cell background color to red
	`$( "td:contains('red')" ).text('Alert'); //Replace text 'red' with 'Alert'
});
</script>
		
"@

$hosts = Get-VMHost | Get-View 														#Retrieve all hosts from vCenter

foreach ($esxihost in $hosts){ 														#For each Host
    foreach($triggered in $esxihost.TriggeredAlarmState){ 							#For each triggered alarm of each host
            $arrayline={} | Select HostName, AlarmType, AlarmInformations 			#Initialize line
            $alarmDefinition = Get-View -Id $triggered.Alarm 						#Get info on Alarm
            $arrayline.HostName = $esxihost.Name 									#Get host which has this alarm triggered
			$arrayline.AlarmType = $triggered.OverallStatus 						#Get if this is a Warning or an Alert
            $arrayline.AlarmInformations = $alarmDefinition.Info.Name 				#Get infos about alarm
            $HostList += $arrayline 												#Add line to array
			$HostList = @($HostList) 												#Post-Declare this is an array which may contain more than one element
    }
}
 
#Outputs the report as an HTML file
ConvertTo-Html -Title "Test Title" -Head "<div id='title'>PowerCLI Alarms</div><div id='subtitle'>Report generated: $(Get-Date)</div>$htmlheader" -Body $($HostList |
 select HostName, AlarmType, AlarmInformations | ConvertTo-Html -Fragment) | Out-File $OutputFile