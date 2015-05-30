
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
        [PSCredential] $RootCredential,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $UserCredential

    )
    
    Import-DscResource -Module xMySql, xPSDesiredStateConfiguration

    node $AllNodes.NodeName
    {
        xMySqlProvision xMySql
        {
            DownloadUri    = $MySQLInstancePackagePath
            ServiceName    = 'MySql'
            DatabaseName   = 'Wordpress'
            RootCredential = $RootCredential
            UserCredential = $UserCredential
        }
    }
}
