#Variable declaration  
$vCenterIPorFQDN="192.168.243.40"  
$vCenterUsername="Administrator@vsphere.local"  
$vCenterPassword="vmware"
$ESXiHost="192.168.243.62"  
$outputFile="C:\Users\Paolo\Desktop\mycharts.html"
$stat = "mem.usage.average" #Stat to measure

#Available stats
#cpu.usage.average
#cpu.usagemhz.average
#mem.usage.average
#disk.usage.average
#net.usage.average
#sys.uptime.latest


Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword

$htmlheader = @"
<html>
  <head>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
	<script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
		['Virtual Machine', 'Average Usage'], //What we are measuring
		
"@


$vms = Get-VMHost -Name $ESXiHost | Get-VM | Where-Object PowerState -match "PoweredOn" #Retrieves all powered on VMs from a specific host
#$vms = Get-VM -Server $vCenterIPorFQDN | Where-Object PowerState -match "PoweredOn" #Retrieves all powered on VMs from a vCenter, depending on the number of hosts/VMs this could take a while

foreach ($vm in $vms) {
		
	$value = Get-Stat -Entity $vm.Name -Stat $stat -Start (Get-Date).AddHours(-24) -MaxSamples (10) -IntervalMins 10 | Measure-Object Value -Average  
	
	$data += "['$vm', $($value.Average)],"
}  

$htmlfooter=@"

        ]);

        var options = {
          title: 'Average Network Usage', //Chart Title
          pieHole: 0.4, //Option regarding this specific kind of chart
        };
		
		var chart = new google.visualization.PieChart(document.getElementById('donutchart'));
        chart.draw(data, options);
      }
    </script>
  </head>
  <body>
  <div id='title'>PowerCLI Google Charts</div>$br<div id='subtitle'>Report generated: $(Get-Date)</div>
  <div id="box1">
  <div id='boxheader'>Average Memory Usage</div>
	<div id='boxcontent'>
		<div id="donutchart" style="width: 900px; height: 500px;"></div>
	</div>
  </div>	
  </body>
</html>
"@

#Generating the output by concatenating strings
$htmlheader + $data + $htmlfooter | Out-File $outputFile