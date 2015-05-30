
configuration SQLInstanceInstallationConfiguration
{
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $MySQLInstancePackagePath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $MySQLInstancePackageName
    )
    
    Import-DscResource -Module xMySql, xPSDesiredStateConfiguration

    node $AllNodes.NodeName
    {
        
        
        xPackage mySqlInstaller
        {
                    
            Path = $MySQLInstancePackagePath
            ProductId = $Node.PackageProductID 
            Name = $MySQLInstancePackageName
        }
        
        xMySqlServer MySQLInstance
        {
            Ensure = "Present"
            RootPassword = $global:cred
            ServiceName = "MySQLServerInstanceName"
            DependsOn = "[xPackage]mySqlInstaller"
        }
    }
}

<# 
Sample use (parameter values need to be changed according to your scenario):
#>

$global:pwd = ConvertTo-SecureString "pass@word1" -AsPlainText -Force
$global:usrName = "administrator"
$global:cred = New-Object -TypeName System.Management.Automation.PSCredential ($global:usrName,$global:pwd)

