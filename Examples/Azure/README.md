# Very Simple DSC Deployment Example

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmgreenegit%2FConfigurationTestExample%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This is a very simple test repo for a DSC configuration example

To test this configuration:

    From Git Shell
    git clone https://github.com/mgreenegit/ConfigurationTestExample
    
    From Azure PowerShell
    New-AzureResourceGroup -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json -Name TestDSC -Location WestUS -locationFromTemplate 'West US'