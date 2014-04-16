<?php

$variable1=$_POST["sendpowercli"];

//Post Data
if ($variable1 != null){
	$command = $variable1;
	$powercli = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -psc \"C:\\Program Files (x86)\\VMware\\Infrastructure\\vSphere PowerCLI\\vim.psc1\" -Command \"& {$command}\"";    
	$query = shell_exec("$powercli");
	
	echo $query;

}

?>