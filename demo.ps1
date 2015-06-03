# Setup Demo 
import-module .\Examples\Azure\AzureProvision.psm1 -Force 
# List the resources
Get-ChildItem .\DscResources

# Let's start with the composite resource
# It is composed of the 4 DSC xMySql Script Resources and
# a package resource.
Get-Content .\DscResources\xMySqlProvision\xMySqlProvision.Schema.psm1

# Let's move on to an example of how to use the 
# Composite resource.
Get-Content .\Examples\Sample_MySQL_Provision.ps1

# Get the existing VM for the demo
$vm = Get-AzureDemoVm 

# Update the vm with the DSC Configuration
Update-AzureDemoMySqlVm -vm $vm -password 'Pa$$word'

# Get the status of the configuration on the VM
Get-AzureVMDscExtensionStatus -VM $vm

# Install the certificate to connect to the machine
Install-AzureVMWinRMCertificate -VM $vm

# Connect to the Azure machine
$session = New-AzureVMPSSession -VM $vm -Credential (Get-Credential -UserName "$($vm.Name)\" -Message 'enter vm password')

# List the database
Invoke-Command -Session $session -ScriptBlock { &'C:\Program Files\MySQL\MySQL Server 5.6\bin\mysql.exe' -e 'show databases' --user=root '--password=Pa$$word' }
