#Variable declaration  
$vCloudIPorFQDN="192.168.243.50"  
$vCloudUsername="User1"  
$vCloudPassword="mypassword"
$vCloudOrganization="HostileCoding"
$outputFile="C:\Users\Paolo\Desktop\mobilereport.html"

#Connecting to vCloud
Connect-CIServer -Server $vCloudIPorFQDN -User $vCloudUsername -Password $vCloudPassword -Org $vCloudOrganization

#Get Organization Informations
$organization = Get-Org

$htmlheader = @"
<html>
<head>
<link rel="stylesheet" href="http://code.jquery.com/mobile/1.4.2/jquery.mobile-1.4.2.min.css" />
<script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
<script src="http://code.jquery.com/mobile/1.4.2/jquery.mobile-1.4.2.min.js"></script>
</head>
"@

$htmlbody1 = @"
<body>
<div data-role="page" id="home">
<div data-role="header">
<h1>$($vCloudOrganization)</h1>
</div>
<div data-role="content">

<div data-role="collapsible">
<h3>$($organization.Name)</h3>
<p>

<ul class="ui-listview ui-listview-inset ui-corner-all ui-shadow" data-inset="true" data-role="listview">
    <li class="ui-li-static ui-body-inherit ui-first-child">
            Enabled	
        <p>
			$($organization.Enabled)
        </p>
    </li>
	<li class="ui-li-static ui-body-inherit ui-first-child">
            Can Publish	
        <p>
			$($organization.CanPublish)
        </p>
    </li>
	<li class="ui-li-static ui-body-inherit ui-first-child">
            Deployed VM Quota	
        <p>
			$($organization.DeployedVMQuota)
        </p>
    </li>
	<li class="ui-li-static ui-body-inherit ui-first-child">
            Stored VM Quota	
        <p>
			$($organization.StoredVMQuota)
        </p>
    </li>
	<li class="ui-li-static ui-body-inherit ui-first-child">
            Catalog Count	
        <p>
			$($organization.CatalogCount)
        </p>
    </li>
	<li class="ui-li-static ui-body-inherit ui-first-child">
            vApp Count	
        <p>
			$($organization.VAppCount)
        </p>
    </li>
</ul>

</p>
</div>
"@

#Get Organization vDC Informations
$organizationvdc = Get-OrgVdc

foreach($vdc in $organizationvdc){

$htmlbody2 += @"
<div data-role="collapsible">
<h3>$($vdc.Name)</h3>
<p>

<ul class="ui-listview ui-listview-inset ui-corner-all ui-shadow" data-inset="true" data-role="listview">
    <li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Allocation Model	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.AllocationModel)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Enabled	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.Enabled)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Cpu Used Ghz	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.CpuUsedGhz)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Cpu Limit Ghz	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.CpuLimitGhz)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Cpu Allocation Ghz	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.CpuAllocationGhz)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Cpu Overhead Ghz	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.CpuOverheadGhz)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Memory Used GB	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.MemoryUsedGB)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Memory Limit GB	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.MemoryLimitGB)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Memory Allocation GB
        <span class="ui-li-count ui-body-inherit">
			$($vdc.MemoryAllocationGB)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Memory Overhead GB
        <span class="ui-li-count ui-body-inherit">
			$($vdc.MemoryOverheadGB)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Storage Used GB	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.StorageUsedGB)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Storage Limit GB	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.StorageLimitGB)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            vApp Count	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.VAppCount)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Status	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.Status)
        </span>
    </li>
	<li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
            Network Max Count	
        <span class="ui-li-count ui-body-inherit">
			$($vdc.NetworkMaxCount)
        </span>
    </li>
</ul>

</p>
</div>
<ul class="ui-listview ui-listview-inset ui-corner-all ui-shadow" data-inset="true" data-filter="true" data-role="listview">
"@

}


#Get Organization vDC Informations
$organizationvapp = Get-CIVApp

foreach($vapp in $organizationvapp){

$htmlbody3 += @"
    <li class="ui-li-static ui-body-inherit ui-li-has-count ui-first-child">
		<h3>
			$($vapp.Name)
		</h3>
		<p>
            <b>Enabled:</b> $($vapp.Enabled)
		</p>
		<p>
            <b>Status:</b> $($vapp.Status)
		</p>
		<p>
            <b>SizeGB:</b> $($vapp.SizeGB)
		</p>
		<p>
            <b>Cpu Count:</b> $($vapp.CpuCount)
		</p>
		<p>
            <b>Memory Allocation MB:</b> $($vapp.MemoryAllocationMB)
		</p>
		<p>
            <b>Maintenance Mode:</b> $($vapp.InMaintenanceMode)
		</p>
		<p>
            <b>Storage Lease:</b> $($vapp.StorageLease)
		</p>
		<p>
            <b>Runtime Lease:</b> $($vapp.RuntimeLease)
		</p>
		<p>
            <b>Owner:</b> $($vapp.Owner)
		</p>
	</li>
"@

}

$htmlfooter=@"
</ul>

</div>
<div data-role="footer">
</div>
</div>
</body>
</html>
"@

#Generating the output by concatenating strings
$htmlheader + $htmlbody1 + $htmlbody2 + $htmlbody3 + $htmlfooter | Out-File -Encoding "UTF8" $outputFile

#Disconnecting from vCloud
Disconnect-CIServer -Confirm:$false