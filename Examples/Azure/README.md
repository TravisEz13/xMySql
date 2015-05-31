# MySql Installation - DSC Deployment Example

<!-- as of 5/2015 GitHub Flavored Markdown does not allow the target attribute, 
     using the workaround of directly using HTML -->
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FTravisEz13%2FxMySql%2FAzureResourceManagerExamples%2FExamples%2FAzure%2FazureInstallMySql.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png" />
</a>

This is a very simple test repo for a DSC configuration example

To test this configuration:

From Git Shell
'''
git clone -branch AzureResourceManagerExamples https://github.com/TravisEz13/xMySql.git
'''    
From Azure PowerShell
'''
New-AzureResourceGroup -TemplateFile .\azureInstallMySql.json -TemplateParameterFile .\azureInstallMySql.parameters.json -Name TestDSC -Location WestUS -locationFromTemplate 'West US'
'''