##################BEGIN FUNCTIONS


function connectServer{

    try {

    $connect = Connect-VIServer -Server $serverTextBox.Text -User $usernameTextBox.Text -Password $passwordTextBox.Text

    $buttonConnect.Enabled = $false #Disable controls once connected
    $serverTextBox.Enabled = $false
    $usernameTextBox.Enabled = $false
    $passwordTextBox.Enabled = $false
    $buttonDisconnect.Enabled = $true #Enable Disconnect button

    getVmHosts #Populate DropDown list with all hosts connected (if vCenter)

    $HostDropDownBox.Enabled=$true
    
    
    $outputTextBox.text = "`nCurrently connected to $($serverTextBox.Text)" #If connection is successfull let user know it

    }

    catch {
    
    $outputTextBox.text = "`nSomething went wrong connecting to server!!"
    
    }

}

function disconnectServer{

    try {

    Disconnect-VIServer -Confirm:$false -Force:$true

    $buttonConnect.Enabled = $true #Enable login controls once disconnected
    $serverTextBox.Enabled = $true
    $usernameTextBox.Enabled = $true
    $passwordTextBox.Enabled = $true
    $buttonDisconnect.Enabled = $false #Disable Disconnect button
    
    $HostDropDownBox.Items.Clear() #Remove all items from DropDown boxes
    $HostDropDownBox.Enabled=$false #Disable DropDown boxes since they are empty
    $VmDropDownBox.Items.Clear()
    $VmDropDownBox.Enabled=$false
    $HardDiskDropDownBox.Items.Clear()
    $HardDiskDropDownBox.Enabled=$false
	$NetworkNameDropDownBox.Items.Clear()
	$NetworkNameDropDownBox.Enabled=$false
	$networkLabelDropDownBox.Items.Clear()
	$networkLabelDropDownBox.Enabled=$false
	$NetworkAdapterDropDownBox.Items.Clear()
	$NetworkAdapterDropDownBox.Enabled=$false
	$numVCpuTextBox.Text = ""
	$numVCpuTextBox.Enabled=$false
	$memSizeGBTextBox.Text = ""
	$memSizeGBTextBox.Enabled=$false
	$diskSizeGBTextBox.Text = ""
	$diskSizeGBTextBox.Enabled=$false
	$macAddressTextBox.Text = ""
	$macAddressTextBox.Enabled=$false
	$wolEnabled.Checked = $false
	$wolEnabled.Enabled = $false
	$connectedEnabled.Checked = $false
	$connectedEnabled.Enabled = $false
	$AddNewHardwareDropDownBox.Items.Clear()
	$AddNewHardwareDropDownBox.Enabled=$false
	$buttonAddHardware.Enabled = $false
	$newDiskSizeGBTextBox.Text = ""
	$newDiskSizeGBTextBox.Enabled=$false
	$independentEnabled.Enabled = $false
	$connectedAtPoweron.Checked = $false
	$connectedAtPoweron.Enabled = $false
	$adapterTypeDropDownBox.Items.Clear()
	$adapterTypeDropDownBox.Enabled = $false
	$networkLabelDropDownBox.Items.Clear()
	$networkLabelDropDownBox.Enabled = $false
	
	
    
    $outputTextBox.text = "`nSuccessfully disconnected from $($serverTextBox.Text)" #If disconnection is successfull let user know it

    }

    catch {
    
    $outputTextBox.text = "`nSomething went wrong disconnecting from server!!"
    
    }

}

function getVmHosts{

    try {

    $vmhosts = Get-VMHost | Where-Object {$_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected"} #Returns only powered On VmHosts

        foreach ($vm in $vmhosts) {
		
            $HostDropDownBox.Items.Add($vm.Name) #Add Hosts to DropDown List
			
        }    

    }

    catch {
    
    $outputTextBox.text = "`nSomething went wrong getting VMHosts!!"
    
    }

}

function getVmsOnHost{

    try {
    
		$outputTextBox.text = "`nGetting Virtual Machines with Hardware Version 10 on VMHost: $($HostDropDownBox.SelectedItem.ToString())"
		
		$v10vms = Get-VM | Where-Object {$_.Version -eq "v10" -and $_.VMHost -eq $(Get-VMHost | Where-Object {$_.Name -eq $HostDropDownBox.SelectedItem.ToString()})} #Returns hardware v10 VMs

		foreach ($vm in $v10vms) {
		
			$VmDropDownBox.Items.Add($vm.Name) #Add VMs to DropDown List
		
		}

		$VmDropDownBox.Enabled=$true

    }

    catch {
    
		$outputTextBox.text = "`nSomething went wrong getting VMHosts!!"
    
    }

}

function getDisks{

    try {
	
	$HardDiskDropDownBox.Enabled = $true #Enable dropdownbox
    
    $harddisks = Get-HardDisk -VM $VmDropDownBox.SelectedItem.ToString()
    
        foreach ($disk in $harddisks) {
		
            $HardDiskDropDownBox.Items.Add($disk.Name) #Add Hosts to DropDown List
			
        }
	
	$HardDiskDropDownBox.SelectedItem = $harddisks.Name #Pre-Select Hard Disk
        
    }
    catch{
       $outputTextBox.text = "`nSomething went wrong getting VmHardDisks!!"
    }
}

function getSelectedDiskSize{

	try {
	
		$diskSizeGBTextBox.text = "" #Clear
		
		$diskSizeGBTextBox.Enabled = $true

		$harddisks = Get-HardDisk -VM $VmDropDownBox.SelectedItem.ToString() -Name $HardDiskDropDownBox.SelectedItem.ToString()
		
		$diskSizeGBTextBox.text = $harddisks.CapacityGB
		
    }
    catch{
       $outputTextBox.text = "`nSomething went wrong getting SelectedDiskSize!!"
    }
}

function getNetwork{

	try{
	
		$NetworkAdapterDropDownBox.Enabled = $true #Enable DropDown Box
		
		$wolEnabled.Enabled = $true
		$connectedEnabled.Enabled = $true
		
		$NetworkAdapterDropDownBox.Items.Clear() #Remove all items from DropDown Box since it may be dirtied by previous executions
		
		$networks= Get-NetworkAdapter -VM $VmDropDownBox.SelectedItem.ToString()
		
		foreach ($network in $networks) {
            
			$NetworkAdapterDropDownBox.Items.Add($network.Name) #Add Networks to DropDown List
        
		}
		
			$NetworkAdapterDropDownBox.SelectedItem = $networks.Name #Pre-Select Network
		
		if($network.WakeOnLanEnabled -match "True"){ #If WOL enabled
		
			$wolEnabled.Checked = $true
		
		}else{
		
			$wolEnabled.Checked = $false
		
		}
		
		if(-Not ($network.ConnectionState -match "NotConnected")){ #If connected
		
			$connectedEnabled.Checked = $true
		
		}else{
		
			$connectedEnabled.Checked = $false
		
		}
	
	}
	catch{
       $outputTextBox.text = "`nSomething went wrong getting Networks!!"
    }
}

function getSelectedNetworkName{
	try {
	
		$NetworkNameDropDownBox.Enabled = $true #Enable DropDown Box
		
		#$macAddressTextBox.Enabled = $true
	
		$NetworkNameDropDownBox.Items.Clear() #Remove all items from DropDown Box since it may be dirtied by previous executions
		$networkLabelDropDownBox.Items.Clear()
		
		$networks = Get-VirtualPortGroup -VMHost $HostDropDownBox.SelectedItem.ToString()
		
		foreach ($network in $networks) {
            $NetworkNameDropDownBox.Items.Add($network.Name) #Add Networks to DropDown List
			$networkLabelDropDownBox.Items.Add($network.Name)
        }
		
		$adapterNetwork = Get-NetworkAdapter -VM $VmDropDownBox.SelectedItem.ToString() -Name $NetworkAdapterDropDownBox.SelectedItem.ToString() #Get networks used by the adapter VM
		
		$NetworkNameDropDownBox.SelectedItem = $adapterNetwork.NetworkName #Pre-select by default the VM Network used by the selected VM
		
		$macAddressTextBox.text = $adapterNetwork.MacAddress
		
		$Label15.Text = $adapterNetwork.Type
		
	}
	catch{
       $outputTextBox.text = "`nSomething went wrong getting SelectedNetworkName!!"
    }
}

function getAddNewHardware{

	try{
		
		if($AddNewHardwareDropDownBox.SelectedItem -match "Hard Disk"){ #Add new Hard Disk
		
			if($independentEnabled.Checked -eq $true){ #Independent
			
				if($persistentRadioButton.Checked -eq $true) { #Independent Persistent
			
					$persistence = "IndependentPersistent"
				
				}elseif($nonPersistentRadioButton.Checked  -eq $true){ #Independent Non Persistent
				
					$persistence = "IndependentNonPersistent"
				
				}
			
			}elseif($independentEnabled.Checked -eq $false){ #Persistent
			
				$persistence = "Persistent"
			
			}
			
			Get-VM -Name $VmDropDownBox.SelectedItem.ToString() | New-HardDisk -CapacityGB $newDiskSizeGBTextBox.Text -Persistence $persistence -Confirm:$false
		
		}
		elseif($AddNewHardwareDropDownBox.SelectedItem.ToString() -match "Network Adapter"){ #Add new Network Adapter
		
			if($connectedAtPoweron.Checked -eq $true){ #Connected at Poweron
			
				$startpoweron = $true
			
			}elseif($connectedAtPoweron.Checked -eq $false){
			
				$startpoweron = $false
			
			}
			if ($adapterTypeDropDownBox.SelectedItem.ToString() -match "E1000"){ #E1000
			
				$adaptertype = "e1000"
			
			}elseif($adapterTypeDropDownBox.SelectedItem.ToString() -match "VMXNET3"){ #VMXNET3
			
				$adaptertype = "vmxnet3"
			
			}elseif($adapterTypeDropDownBox.SelectedItem.ToString() -match "E1000E"){ #E1000E
			
				$adaptertype = "EnhancedVmxnet"
			
			}
		
			Get-VM -Name $VmDropDownBox.SelectedItem.ToString() | New-NetworkAdapter -NetworkName $networkLabelDropDownBox.SelectedItem.ToString() -StartConnected:$startpoweron -Type $adaptertype
		
		}
	
	getVmConfigs #Refresh data in Text Boxes
	
	}catch{
       $outputTextBox.text = "`nSomething went wrong getting AddNewHardware!!"
    }
}

function getVmConfigs{

	try {
	
		$outputTextBox.text = "`nGetting configs for VM: $($VmDropDownBox.SelectedItem.ToString())"
	
		$numVCpuTextBox.Enabled = $true #Enable TextBoxes
		$memSizeGBTextBox.Enabled = $true
		$buttonSetVm.Enabled = $true
		
		$AddNewHardwareDropDownBox.Enabled=$true #Enable Add new Hardware
		
		$HardDiskDropDownBox.Items.Clear() #Remove all items from GroupBox since it may be dirtied by previous executions
		$NetworkNameDropDownBox.Items.Clear()
		$NetworkAdapterDropDownBox.Items.Clear()
		$AddNewHardwareDropDownBox.Items.Clear()
		$connectedAtPoweron.Checked = $false
		$connectedAtPoweron.Enabled = $false
		$adapterTypeDropDownBox.Items.Clear()
		$adapterTypeDropDownBox.Enabled = $false
		$networkLabelDropDownBox.Items.Clear()
		$networkLabelDropDownBox.Enabled = $false
		$independentEnabled.Enabled = $false
		$persistentRadioButton.Enabled = $false
		$nonPersistentRadioButton.Enabled = $false	
		
		$numVCpuTextBox.Text = "";
		$memSizeGBTextBox.Text = "";
		$diskSizeGBTextBox.Text = ""
		$macAddressTextBox.Text = ""
		$newDiskSizeGBTextBox.Text = ""
		$newDiskSizeGBTextBox.Enabled = $false

		$VmInfos = Get-VM -Name $VmDropDownBox.SelectedItem.ToString()

		$numVCpuTextBox.text = $VmInfos.NumCPU
		$memSizeGBTextBox.text = $VmInfos.MemoryGB

		getDisks
		
		getNetwork
		
		$hwsList=@("Hard Disk","Network Adapter") #Populate DropDownBox. By calling it in this method list is populated even if a reconnection occurs.

		foreach ($hw in $hwsList) {
			$AddNewHardwareDropDownBox.Items.Add($hw)
		}
		
		$typeList=@("E1000","VMXNET3", "E1000E")

		foreach ($types in $typeList) {
			$adapterTypeDropDownBox.Items.Add($types)
		}
	
	}
    catch{
       $outputTextBox.text = "`nSomething went wrong getting VmConfigs!!"
    }

}

function setVmConfigs{

	try {
	
	$numVCpu = $numVCpuTextBox.Text -as [int] #Convert values to integer
	$memSizeGB = $memSizeGBTextBox.Text -as [int]
	$diskSizeGB = $diskSizeGBTextBox.Text -as [int]
	
	Get-VM -Name $VmDropDownBox.SelectedItem.ToString() | Set-VM -NumCpu $numVCpu -MemoryGB $memSizeGB -Confirm:$false 
	
	if ($HardDiskDropDownBox.Text.Length -gt 0) {
	
		Get-HardDisk -VM $VmDropDownBox.SelectedItem.ToString() -Name $HardDiskDropDownBox.SelectedItem.ToString() | Set-HardDisk -CapacityGB $diskSizeGB -Confirm:$false
        
    }else {

		$outputTextBox.text = "`nTo change HardDisk size you must first select one virtual disk!!"
		
	}
	
	if (($NetworkAdapterDropDownBox.Text.Length -gt 0) -and ($NetworkNameDropDownBox.Text.Length -gt 0)) {
		
		if ($wolEnabled.Checked -eq $true){ #Set Wake On LAN
		
			$wol = $true
		
		}elseif($wolEnabled.Checked -eq $false){
		
			$wol = $false
		
		}
		
		if ($connectedEnabled.Checked -eq $true){ #Set Connected
		
			$connected = $true
		
		}elseif($connectedEnabled.Checked -eq $false){
		
			$connected = $false
		
		}
		
		#Set-NetworkAdapter -MacAddress $macAddressTextBox.Text
		
		Set-NetworkAdapter -NetworkAdapter (Get-NetworkAdapter -VM $VmDropDownBox.SelectedItem.ToString() -Name $NetworkAdapterDropDownBox.SelectedItem.ToString()) -NetworkName $NetworkNameDropDownBox.SelectedItem.ToString() -WakeOnLan $wol -Connected $connected -Confirm:$false
		
	}else {

		$outputTextBox.text = "`nTo change Network Adapter settings you must first select one!!"
		
	}
	
	getVmConfigs #Refresh data in Text Boxes
		
	}
    catch{
       $outputTextBox.text = "`nSomething went wrong setting VmConfigs!!"
    }
}

##################END FUNCTIONS

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

##################Main Form Definition
    
    $main_form = New-Object System.Windows.Forms.Form 
    $main_form.Text = "Edit VM Hardware v10" #Form Title
    $main_form.Size = New-Object System.Drawing.Size(425,815) 
    $main_form.StartPosition = "CenterScreen"

    $main_form.KeyPreview = $True
    $main_form.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$main_form.Close()}})

##################GroupBox Definition

    $groupBox1 = New-Object System.Windows.Forms.GroupBox
    $groupBox1.Location = New-Object System.Drawing.Size(10,5) 
    $groupBox1.size = New-Object System.Drawing.Size(190,200) #Width, Heigth
    $groupBox1.text = "Connect to vCenter or ESXi host:" 
    $main_form.Controls.Add($groupBox1) 

    $groupBox2 = New-Object System.Windows.Forms.GroupBox
    $groupBox2.Location = New-Object System.Drawing.Size(10,215) 
    $groupBox2.size = New-Object System.Drawing.Size(390,60) #Width, Heigth
    $groupBox2.text = "Hosts Operations:" 
    $main_form.Controls.Add($groupBox2) 

    $groupBox3 = New-Object System.Windows.Forms.GroupBox
    $groupBox3.Location = New-Object System.Drawing.Size(10,285) 
    $groupBox3.size = New-Object System.Drawing.Size(390,410) #Width, Heigth
    $groupBox3.text = "VMs Operations:" 
    $main_form.Controls.Add($groupBox3) 

    $groupBox4 = New-Object System.Windows.Forms.GroupBox
    $groupBox4.Location = New-Object System.Drawing.Size(10,700) 
    $groupBox4.size = New-Object System.Drawing.Size(390,70) #Width, Heigth
    $groupBox4.text = "Output:" 
    $main_form.Controls.Add($groupBox4)
    
    $groupBox5 = New-Object System.Windows.Forms.GroupBox
    $groupBox5.Location = New-Object System.Drawing.Size(210,5) 
    $groupBox5.size = New-Object System.Drawing.Size(190,200) #Width, Heigth
    $groupBox5.text = "Instructions:" 
    $main_form.Controls.Add($groupBox5)  

##################Label Definition

    $Label1 = New-Object System.Windows.Forms.Label
    $Label1.Location = New-Object System.Drawing.Point(10, 20)
    $Label1.Size = New-Object System.Drawing.Size(120, 14)
    $Label1.Text = "IP Address or FQDN:"
    $groupBox1.Controls.Add($Label1) #Member of GroupBox1

    $Label2 = New-Object System.Windows.Forms.Label
    $Label2.Location = New-Object System.Drawing.Point(10, 70)
    $Label2.Size = New-Object System.Drawing.Size(120, 14)
    $Label2.Text = "Username:"
    $groupBox1.Controls.Add($Label2) #Member of GroupBox1

    $Label3 = New-Object System.Windows.Forms.Label
    $Label3.Location = New-Object System.Drawing.Point(10, 120)
    $Label3.Size = New-Object System.Drawing.Size(120, 14)
    $Label3.Text = "Password:"
    $groupBox1.Controls.Add($Label3) #Member of GroupBox1
    
    $Label4 = New-Object System.Windows.Forms.Label
    $Label4.Location = New-Object System.Drawing.Point(10, 15)
    $Label4.Size = New-Object System.Drawing.Size(120, 14)
    $Label4.Text = "Select Host:"
    $groupBox2.Controls.Add($Label4) #Member of GroupBox2
    
    $Label5 = New-Object System.Windows.Forms.Label
    $Label5.Location = New-Object System.Drawing.Point(10, 15)
    $Label5.Size = New-Object System.Drawing.Size(120, 14)
    $Label5.Text = "Select VM:"
    $groupBox3.Controls.Add($Label5) #Member of GroupBox3
    
    $Label6 = New-Object System.Windows.Forms.Label
    $Label6.Location = New-Object System.Drawing.Point(10, 55)
    $Label6.Size = New-Object System.Drawing.Size(90, 14)
    $Label6.Text = "Num vCPU:"
    $groupBox3.Controls.Add($Label6) #Member of GroupBox3
    
    $Label7 = New-Object System.Windows.Forms.Label
    $Label7.Location = New-Object System.Drawing.Point(200, 55)
    $Label7.Size = New-Object System.Drawing.Size(160, 14)
    $Label7.Text = "Memory size in GB:"
    $groupBox3.Controls.Add($Label7) #Member of GroupBox3
    
    $Label8 = New-Object System.Windows.Forms.Label
    $Label8.Location = New-Object System.Drawing.Point(10, 95)
    $Label8.Size = New-Object System.Drawing.Size(80, 14)
    $Label8.Text = "Hard Disk:"
    $groupBox3.Controls.Add($Label8) #Member of GroupBox3
    
    $Label9 = New-Object System.Windows.Forms.Label
    $Label9.Location = New-Object System.Drawing.Point(10, 15)
    $Label9.Size = New-Object System.Drawing.Size(170, 180)
    $Label9.Text = "1)Connect to vCenter or ESXi host `r`n`r`n2)Select host and get v10 VMs `r`n`r`n3)Select VM `r`n`r`n4)Modify VM settings`r`n`r`n5)Apply Changes `r`n`r`n6)If needed add new hardware`r`n`r`n`Developed by @HostileCoding"
    $groupBox5.Controls.Add($Label9) #Member of GroupBox3
	
	$Label10 = New-Object System.Windows.Forms.Label
    $Label10.Location = New-Object System.Drawing.Point(200, 95)
    $Label10.Size = New-Object System.Drawing.Size(120, 14)
    $Label10.Text = "Hard Disk size in GB:"
    $groupBox3.Controls.Add($Label10) #Member of GroupBox3
	
	$Label11 = New-Object System.Windows.Forms.Label
    $Label11.Location = New-Object System.Drawing.Point(10, 135)
    $Label11.Size = New-Object System.Drawing.Size(120, 14)
    $Label11.Text = "Network Adapter:"
    $groupBox3.Controls.Add($Label11) #Member of GroupBox3
	
	$Label12 = New-Object System.Windows.Forms.Label
    $Label12.Location = New-Object System.Drawing.Point(200, 135)
    $Label12.Size = New-Object System.Drawing.Size(120, 14)
    $Label12.Text = "Network Name:"
    $groupBox3.Controls.Add($Label12) #Member of GroupBox3
	
	$Label13 = New-Object System.Windows.Forms.Label
    $Label13.Location = New-Object System.Drawing.Point(10, 175)
    $Label13.Size = New-Object System.Drawing.Size(120, 14)
    $Label13.Text = "MAC Address:"
    $groupBox3.Controls.Add($Label13) #Member of GroupBox3
	
	$Label14 = New-Object System.Windows.Forms.Label
    $Label14.Location = New-Object System.Drawing.Point(200, 175)
    $Label14.Size = New-Object System.Drawing.Size(40, 14)
    $Label14.Text = "Type:"
    $groupBox3.Controls.Add($Label14) #Member of GroupBox3
	
	$Label15 = New-Object System.Windows.Forms.Label
    $Label15.Location = New-Object System.Drawing.Point(240, 175)
    $Label15.Size = New-Object System.Drawing.Size(100, 14)
    $groupBox3.Controls.Add($Label15) #Member of GroupBox3
	
	$Label16 = New-Object System.Windows.Forms.Label
    $Label16.Location = New-Object System.Drawing.Point(10, 240)
    $Label16.Size = New-Object System.Drawing.Size(120, 14)
	$Label16.Text = "Add New Hardware:"
    $groupBox3.Controls.Add($Label16) #Member of GroupBox3
	
	$Label17 = New-Object System.Windows.Forms.Label
    $Label17.Location = New-Object System.Drawing.Point(10, 280)
    $Label17.Size = New-Object System.Drawing.Size(120, 14)
    $Label17.Text = "Hard Disk size in GB:"
    $groupBox3.Controls.Add($Label17) #Member of GroupBox3
	
	$Label18 = New-Object System.Windows.Forms.Label
    $Label18.Location = New-Object System.Drawing.Point(10, 320)
    $Label18.Size = New-Object System.Drawing.Size(120, 14)
    $Label18.Text = "Adapter Type:"
    $groupBox3.Controls.Add($Label18) #Member of GroupBox3
	
	$Label19 = New-Object System.Windows.Forms.Label
    $Label19.Location = New-Object System.Drawing.Point(200, 320)
    $Label19.Size = New-Object System.Drawing.Size(120, 14)
    $Label19.Text = "Network Label:"
    $groupBox3.Controls.Add($Label19) #Member of GroupBox3

##################Button Definition

    $buttonConnect = New-Object System.Windows.Forms.Button
    $buttonConnect.add_click({connectServer})
    $buttonConnect.Text = "Connect"
    $buttonConnect.Top=170
    $buttonConnect.Left=10
    $groupBox1.Controls.Add($buttonConnect) #Member of GroupBox1

    $buttonDisconnect = New-Object System.Windows.Forms.Button
    $buttonDisconnect.add_click({disconnectServer})
    $buttonDisconnect.Text = "Disconnect"
    $buttonDisconnect.Top=170
    $buttonDisconnect.Left=100
    $buttonDisconnect.Enabled = $false #Disabled by default
    $groupBox1.Controls.Add($buttonDisconnect) #Member of GroupBox1

    $buttonvGetVms = New-Object System.Windows.Forms.Button
    $buttonvGetVms.Size = New-Object System.Drawing.Size(180,25) 
    $buttonvGetVms.add_click({getVmsOnHost})
    $buttonvGetVms.Text = "Get VMs for selected Host"
    $buttonvGetVms.Left=200
    $buttonvGetVms.Top=25
    $groupBox2.Controls.Add($buttonvGetVms) #Member of GroupBox2
    
    $buttonSetVm = New-Object System.Windows.Forms.Button
    $buttonSetVm.Size = New-Object System.Drawing.Size(370,20) 
    $buttonSetVm.add_click({setVmConfigs})
    $buttonSetVm.Text = "Apply Changes"
    $buttonSetVm.Left=10
    $buttonSetVm.Top=215
    $buttonSetVm.Enabled = $false #Disabled by default
    $groupBox3.Controls.Add($buttonSetVm) #Member of GroupBox3
	
	$buttonAddHardware = New-Object System.Windows.Forms.Button
    $buttonAddHardware.Size = New-Object System.Drawing.Size(370,20) 
    $buttonAddHardware.add_click({getAddNewHardware})
    $buttonAddHardware.Text = "Add Hardware"
    $buttonAddHardware.Left=10
    $buttonAddHardware.Top=380
    $buttonAddHardware.Enabled = $false #Disabled by default
    $groupBox3.Controls.Add($buttonAddHardware) #Member of GroupBox3

##################CheckBox Definition	
	
	$wolEnabled = New-Object System.Windows.Forms.checkbox
	$wolEnabled.Location = New-Object System.Drawing.Size(200, 190)
	$wolEnabled.Size = New-Object System.Drawing.Size(100,20)
	$wolEnabled.Enabled = $false
	$wolEnabled.Checked = $false
	$wolEnabled.Text = "Wake on LAN"
	$groupBox3.Controls.Add($wolEnabled) #Member of GroupBox3
	
	$connectedEnabled = New-Object System.Windows.Forms.checkbox
	$connectedEnabled.Location = New-Object System.Drawing.Size(300, 190)
	$connectedEnabled.Size = New-Object System.Drawing.Size(80,20)
	$connectedEnabled.Enabled = $false
	$connectedEnabled.Checked = $false
	$connectedEnabled.Text = "Connected"
	$groupBox3.Controls.Add($connectedEnabled) #Member of GroupBox3
	
	$independentEnabled = New-Object System.Windows.Forms.checkbox
	$independentEnabled.Location = New-Object System.Drawing.Size(200, 280)
	$independentEnabled.Size = New-Object System.Drawing.Size(150,20)
	$independentEnabled.Enabled = $false
	$independentEnabled.Checked = $false
	$independentEnabled.Text = "Independent"
	$groupBox3.Controls.Add($independentEnabled) #Member of GroupBox3
	
	$independentEnabled.Add_CheckStateChanged({ #Checkbox Enabled
    
		if ($independentEnabled.Checked) {
		
			$persistentRadioButton.Enabled = $true
			$nonPersistentRadioButton.Enabled = $true
				
		}else{
		
			$persistentRadioButton.Enabled = $false
			$nonPersistentRadioButton.Enabled = $false
		
		}
		
	})
	
	$connectedAtPoweron = New-Object System.Windows.Forms.checkbox
	$connectedAtPoweron.Location = New-Object System.Drawing.Size(10, 360)
	$connectedAtPoweron.Size = New-Object System.Drawing.Size(150,20)
	$connectedAtPoweron.Enabled = $false
	$connectedAtPoweron.Checked = $false
	$connectedAtPoweron.Text = "Connect at poweron"
	$groupBox3.Controls.Add($connectedAtPoweron) #Member of GroupBox3
	
##################RadioButton Definition

	$persistentRadioButton = New-Object System.Windows.Forms.RadioButton 
	$persistentRadioButton.Location = new-object System.Drawing.Point(200,300) 
	$persistentRadioButton.size = New-Object System.Drawing.Size(80,20) 
	$persistentRadioButton.Checked = $true 
	$persistentRadioButton.Enabled = $false
	$persistentRadioButton.Text = "Persistent" 
	$groupBox3.Controls.Add($persistentRadioButton)	
	
	$nonPersistentRadioButton = New-Object System.Windows.Forms.RadioButton 
	$nonPersistentRadioButton.Location = new-object System.Drawing.Point(280,300) 
	$nonPersistentRadioButton.size = New-Object System.Drawing.Size(100,20) 
	$nonPersistentRadioButton.Checked = $false 
	$nonPersistentRadioButton.Enabled = $false
	$nonPersistentRadioButton.Text = "Non Persistent" 
	$groupBox3.Controls.Add($nonPersistentRadioButton)	

##################TextBox Definition

    $serverTextBox = New-Object System.Windows.Forms.TextBox 
    $serverTextBox.Location = New-Object System.Drawing.Size(10,40) #Left, Top, Right, Bottom
    $serverTextBox.Size = New-Object System.Drawing.Size(165,20)
    $groupBox1.Controls.Add($serverTextBox) #Member of GroupBox1

    $usernameTextBox = New-Object System.Windows.Forms.TextBox 
    $usernameTextBox.Location = New-Object System.Drawing.Size(10,90)
    $usernameTextBox.Size = New-Object System.Drawing.Size(165,20) 
    $groupBox1.Controls.Add($usernameTextBox) #Member of GroupBox1

    $passwordTextBox = New-Object System.Windows.Forms.MaskedTextBox #Password TextBox
    $passwordTextBox.PasswordChar = '*'
    $passwordTextBox.Location = New-Object System.Drawing.Size(10,140)
    $passwordTextBox.Size = New-Object System.Drawing.Size(165,20)
    $groupBox1.Controls.Add($passwordTextBox) #Member of GroupBox1
    
    $numVCpuTextBox = New-Object System.Windows.Forms.TextBox
    $numVCpuTextBox.Location = New-Object System.Drawing.Size(10,70)
    $numVCpuTextBox.Size = New-Object System.Drawing.Size(180,20)
    $numVCpuTextBox.Enabled=$false 
    $groupBox3.Controls.Add($numVCpuTextBox) #Member of GroupBox3
    
    $memSizeGBTextBox = New-Object System.Windows.Forms.TextBox
    $memSizeGBTextBox.Location = New-Object System.Drawing.Size(200,70)
    $memSizeGBTextBox.Size = New-Object System.Drawing.Size(180,20)
    $memSizeGBTextBox.Enabled=$false 
    $groupBox3.Controls.Add($memSizeGBTextBox) #Member of GroupBox3
	
	$diskSizeGBTextBox = New-Object System.Windows.Forms.TextBox
    $diskSizeGBTextBox.Location = New-Object System.Drawing.Size(200,110)
    $diskSizeGBTextBox.Size = New-Object System.Drawing.Size(180,20)
    $diskSizeGBTextBox.Enabled=$false 
    $groupBox3.Controls.Add($diskSizeGBTextBox) #Member of GroupBox3
	
	$macAddressTextBox = New-Object System.Windows.Forms.TextBox
    $macAddressTextBox.Location = New-Object System.Drawing.Size(10,190)
    $macAddressTextBox.Size = New-Object System.Drawing.Size(180,20)
    $macAddressTextBox.Enabled=$false 
    $groupBox3.Controls.Add($macAddressTextBox) #Member of GroupBox3
	
	$newDiskSizeGBTextBox = New-Object System.Windows.Forms.TextBox
    $newDiskSizeGBTextBox.Location = New-Object System.Drawing.Size(10,295)
    $newDiskSizeGBTextBox.Size = New-Object System.Drawing.Size(180,20)
    $newDiskSizeGBTextBox.Enabled=$false 
    $groupBox3.Controls.Add($newDiskSizeGBTextBox) #Member of GroupBox3

    $outputTextBox = New-Object System.Windows.Forms.TextBox 
    $outputTextBox.Location = New-Object System.Drawing.Size(10,20)
    $outputTextBox.Size = New-Object System.Drawing.Size(370,40)
    $outputTextBox.MultiLine = $True 
    $outputTextBox.ReadOnly = $True
    $outputTextBox.ScrollBars = "Vertical"  
    $groupBox4.Controls.Add($outputTextBox) #Member of groupBox4

##################DropDownBox Definition

    $VmDropDownBox = New-Object System.Windows.Forms.ComboBox
    $VmDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList #Disable user input in ComboBox
    $VmDropDownBox.Location = New-Object System.Drawing.Size(10,30) 
    $VmDropDownBox.Size = New-Object System.Drawing.Size(370,20) 
    $VmDropDownBox.DropDownHeight = 200
    $VmDropDownBox.Enabled=$false 
    $groupBox3.Controls.Add($VmDropDownBox)
    
    $handler_VmDropDownBox_SelectedIndexChanged={ #DropDownBox SelectedIndexChanged Handler
        try{
            if ($VmDropDownBox.Text.Length -gt 0) {
			   getVmConfigs
            }
        }catch{
        }
    }
    $VmDropDownBox.add_SelectedIndexChanged($handler_VmDropDownBox_SelectedIndexChanged)

    $HostDropDownBox = New-Object System.Windows.Forms.ComboBox
    $HostDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList #Disable user input in ComboBox
    $HostDropDownBox.Location = New-Object System.Drawing.Size(10,30) 
    $HostDropDownBox.Size = New-Object System.Drawing.Size(180,20) 
    $HostDropDownBox.DropDownHeight = 200
    $HostDropDownBox.Enabled=$false 
    $groupBox2.Controls.Add($HostDropDownBox)
    
    $HardDiskDropDownBox = New-Object System.Windows.Forms.ComboBox
    $HardDiskDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList #Disable user input in ComboBox
    $HardDiskDropDownBox.Location = New-Object System.Drawing.Size(10,110) 
    $HardDiskDropDownBox.Size = New-Object System.Drawing.Size(180,20) 
    $HardDiskDropDownBox.DropDownHeight = 200
    $HardDiskDropDownBox.Enabled=$false 
    $groupBox3.Controls.Add($HardDiskDropDownBox)
    
    $handler_HardDiskDropDownBox_SelectedIndexChanged={ #DropDownBox SelectedIndexChanged Handler
        try{
            if ($HardDiskDropDownBox.Text.Length -gt 0) {
			   getSelectedDiskSize
            }
        }catch{
        }
    }
    $HardDiskDropDownBox.add_SelectedIndexChanged($handler_HardDiskDropDownBox_SelectedIndexChanged)
	
	$NetworkAdapterDropDownBox = New-Object System.Windows.Forms.ComboBox
    $NetworkAdapterDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList #Disable user input in ComboBox
    $NetworkAdapterDropDownBox.Location = New-Object System.Drawing.Size(10,150) 
    $NetworkAdapterDropDownBox.Size = New-Object System.Drawing.Size(180,20) 
    $NetworkAdapterDropDownBox.DropDownHeight = 200
    $NetworkAdapterDropDownBox.Enabled=$false 
    $groupBox3.Controls.Add($NetworkAdapterDropDownBox)
	
	$handler_NetworkAdapterDropDownBox_SelectedIndexChanged={ #DropDownBox SelectedIndexChanged Handler
        try{
            if ($NetworkAdapterDropDownBox.Text.Length -gt 0) {
			   getSelectedNetworkName
            }
        }catch{	
        }
    }
    $NetworkAdapterDropDownBox.add_SelectedIndexChanged($handler_NetworkAdapterDropDownBox_SelectedIndexChanged)
	
	$NetworkNameDropDownBox = New-Object System.Windows.Forms.ComboBox
    $NetworkNameDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList #Disable user input in ComboBox
    $NetworkNameDropDownBox.Location = New-Object System.Drawing.Size(200,150) 
    $NetworkNameDropDownBox.Size = New-Object System.Drawing.Size(180,20) 
    $NetworkNameDropDownBox.DropDownHeight = 200
    $NetworkNameDropDownBox.Enabled=$false 
    $groupBox3.Controls.Add($NetworkNameDropDownBox)
	
	$AddNewHardwareDropDownBox = New-Object System.Windows.Forms.ComboBox
    $AddNewHardwareDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList #Disable user input in ComboBox
    $AddNewHardwareDropDownBox.Location = New-Object System.Drawing.Size(10,255) 
    $AddNewHardwareDropDownBox.Size = New-Object System.Drawing.Size(370,20) 
    $AddNewHardwareDropDownBox.DropDownHeight = 200
    $AddNewHardwareDropDownBox.Enabled=$false 
    $groupBox3.Controls.Add($AddNewHardwareDropDownBox)
	
	$handler_AddNewHardwareDropDownBox_SelectedIndexChanged={ #DropDownBox SelectedIndexChanged Handler
        try{
            if ($AddNewHardwareDropDownBox.Text.Length -gt 0) {
			
				$buttonAddHardware.Enabled = $true
				
				if ($AddNewHardwareDropDownBox.SelectedItem.ToString() -match "Hard Disk") {
				
					$newDiskSizeGBTextBox.Enabled = $true	#Enable components
					$independentEnabled.Enabled = $true
					
					$connectedAtPoweron.Enabled = $false	#Disable components
					$adapterTypeDropDownBox.Enabled = $false
					$networkLabelDropDownBox.Enabled = $false
					
				}
				elseif($AddNewHardwareDropDownBox.SelectedItem.ToString() -match "Network Adapter"){
				
					$connectedAtPoweron.Enabled = $true		#Enable components
					$adapterTypeDropDownBox.Enabled = $true
					$networkLabelDropDownBox.Enabled = $true
				
					$newDiskSizeGBTextBox.Enabled = $false	#Disable components
					$independentEnabled.Enabled = $false
					$persistentRadioButton.Enabled = $false
					$nonPersistentRadioButton.Enabled = $false
					
					$adapterTypeDropDownBox.Items.Clear() #Clear DropDown Box since it could be dirtied
					
					$typeList=@("E1000","VMXNET3", "E1000E")

					foreach ($types in $typeList) {
						$adapterTypeDropDownBox.Items.Add($types)
					}
					
				}	
				
            }
        }catch{	
        }
    }
    $AddNewHardwareDropDownBox.add_SelectedIndexChanged($handler_AddNewHardwareDropDownBox_SelectedIndexChanged)	
	
	$adapterTypeDropDownBox = New-Object System.Windows.Forms.ComboBox
    $adapterTypeDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList #Disable user input in ComboBox
    $adapterTypeDropDownBox.Location = New-Object System.Drawing.Size(10,335) 
    $adapterTypeDropDownBox.Size = New-Object System.Drawing.Size(180,20) 
    $adapterTypeDropDownBox.DropDownHeight = 200
    $adapterTypeDropDownBox.Enabled=$false 
    $groupBox3.Controls.Add($adapterTypeDropDownBox)

	$networkLabelDropDownBox = New-Object System.Windows.Forms.ComboBox
    $networkLabelDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList #Disable user input in ComboBox
    $networkLabelDropDownBox.Location = New-Object System.Drawing.Size(200,335) 
    $networkLabelDropDownBox.Size = New-Object System.Drawing.Size(180,20) 
    $networkLabelDropDownBox.DropDownHeight = 200
    $networkLabelDropDownBox.Enabled=$false 
    $groupBox3.Controls.Add($networkLabelDropDownBox)	

##################Show Form

    $main_form.Add_Shown({$main_form.Activate()})
    [void] $main_form.ShowDialog()