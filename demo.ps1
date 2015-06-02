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
