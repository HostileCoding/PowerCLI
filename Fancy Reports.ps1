#Variable declaration
$vCenterIPorFQDN="10.0.1.210"
$vCenterUsername="Administrator@vsphere.local"
$vCenterPassword="vmware"
$LocationName="Datacenter" #This could be: Datacenter Name, Cluster Name, Host Name
$ClusterName="TestCluster" #Name of the Cluster on which you need to run the report
$OutputPath="C:\" #Location where you want to place generated report

Write-Host "Connecting to vCenter" -foregroundcolor "magenta" 
Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword

#This is the CSS used to add the style to the report

$Css="<style>
body {
    font-family: Verdana, sans-serif;
    font-size: 14px;
	color: #666666;
	background: #FEFEFE;
}
#title{
	color:#90B800;
	font-size: 30px;
	font-weight: bold;
	padding-top:25px;
	margin-left:35px;
	height: 50px;
}
#subtitle{
	font-size: 11px;
	margin-left:35px;
}
#main {
	position:relative;
	padding-top:10px;
	padding-left:10px;
	padding-bottom:10px;
	padding-right:10px;
}
#box1{
	position:absolute;
	background: #F8F8F8;
	border: 1px solid #DCDCDC;
	margin-left:10px;
	padding-top:10px;
	padding-left:10px;
	padding-bottom:10px;
	padding-right:10px;
}
#boxheader{
	font-family: Arial, sans-serif;
	padding: 5px 20px;
	position: relative;
	z-index: 20;
	display: block;
	height: 30px;
	color: #777;
	text-shadow: 1px 1px 1px rgba(255,255,255,0.8);
	line-height: 33px;
	font-size: 19px;
	background: #fff;
	background: -moz-linear-gradient(top, #ffffff 1%, #eaeaea 100%);
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#ffffff), color-stop(100%,#eaeaea));
	background: -webkit-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	background: -o-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	background: -ms-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	background: linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ffffff', endColorstr='#eaeaea',GradientType=0 );
	box-shadow: 
		0px 0px 0px 1px rgba(155,155,155,0.3), 
		1px 0px 0px 0px rgba(255,255,255,0.9) inset, 
		0px 2px 2px rgba(0,0,0,0.1);
}

table{
	width:100%;
	border-collapse:collapse;
}
table td, table th {
	border:1px solid #98bf21;
	padding:3px 7px 2px 7px;
}
table th {
	text-align:left;
	padding-top:5px;
	padding-bottom:4px;
	background-color:#90B800;
color:#fff;
}
table tr.alt td {
	color:#000;
	background-color:#EAF2D3;
}
</style>"

#These are divs declarations used to properly style HTML using previously defined CSS

$PageBoxOpener="<div id='box1'>"
$ReportVmHost="<div id='boxheader'>Get-VMHost $LocationName</div>"
$BoxContentOpener="<div id='boxcontent'>"
$PageBoxCloser="</div>"
$br="<br>" #This should have been defined in CSS but if you need new line you could also use it this way
$ReportGetCluster="<div id='boxheader'>Get-Cluster $ClusterName</div>"
$ReportGetVmCluster="<div id='boxheader'>Get-VM $ClusterName</div>"

#Get VMHost infos
$VmHost=Get-VMHost -Location $LocationName | Select-Object @{Name = 'Host'; Expression = {$_.Name}},State,ConnectionState,PowerState,Model,Version,Build,NumCpu,@{Name = 'CpuTotalGhz'; Expression = {"{0:N2}" -f ($_.CpuTotalMhz/1000)}},@{Name = 'CpuUsageGhz'; Expression = {"{0:N2}" -f ($_.CpuUsageMhz/1000)}},@{Name = 'MemoryTotalGB'; Expression = {"{0:N2}" -f $_.MemoryTotalGB}}, @{Name = 'MemoryUsageGB'; Expression = {"{0:N2}" -f $_.MemoryUsageGB}} | ConvertTo-HTML -Fragment

#Get Cluster infos
$GetCluster=Get-Cluster -Name $ClusterName | Select-Object Name, HAEnabled, HAIsolationResponse,@{Name = 'DRS Enabled'; Expression = {$_.DrsEnabled}},@{Name = 'DRS'; Expression = {$_.DrsAutomationLevel}},VsanEnabled,VsanDiskClaimMode | ConvertTo-HTML -Fragment

#Get VM infos
$GetVmCluster=Get-VM -Location (Get-Cluster -Name $ClusterName) | Select-Object Name,PowerState,NumCPU, MemoryGB | Sort-Object Name | ConvertTo-HTML -Fragment

#Create HTML report
#-Head parameter could be omitted if header is declared in body
ConvertTo-Html -Title "Test Title" -Head "<div id='title'>PowerCLI Reporting</div>$br<div id='subtitle'>Report generated: $(Get-Date)</div>
" -Body " $Css $PageBoxOpener $ReportVmHost $BoxContentOpener $VmHost $PageBoxCloser $br $ReportGetCluster $BoxContentOpener $GetCluster $PageBoxCloser $br $ReportGetVmCluster $BoxContentOpener $GetVmCluster $PageBoxCloser
"  | Out-File $OutputPath\Report.html

