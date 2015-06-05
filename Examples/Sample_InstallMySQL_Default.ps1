
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
            ProductId = '{437AC169-780B-47A9-86F6-14D43C8F596B}'
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

