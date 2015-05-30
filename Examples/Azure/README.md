# Very Simple DSC Deployment Example

[![Deploy To Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FTravisEz13%2FxMySql%2FAzureResourceManagerExamples%2FExamples%2FAzure%2FazureInstallMySql.json)

This is a very simple test repo for a DSC configuration example

To test this configuration:

    From Git Shell
    git clone -branch AzureResourceManagerExamples https://github.com/TravisEz13/xMySql.git
    
    From Azure PowerShell
    New-AzureResourceGroup -TemplateFile .\azureInstallMySql.json -TemplateParameterFile .\azureInstallMySql.parameters.json -Name TestDSC -Location WestUS -locationFromTemplate 'West US'