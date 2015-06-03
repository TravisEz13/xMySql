
configuration SQLInstanceInstallationConfiguration
{
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $MySQLInstancePackagePath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $MySQLInstancePackageName,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $RootCredential
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
            Ensure = 'Present'
            RootPassword = $RootCredential
            ServiceName = 'MySQLServerInstanceName'
            DependsOn = '[xPackage]mySqlInstaller'
        }
    }
}

