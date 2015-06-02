[cmdletbinding()]
Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AdminUsername,
        [ValidateNotNullOrEmpty()]
        [string]
        $location = 'West US',
        [ValidateNotNullOrEmpty()]
        [string]
        $machineName,
        [Parameter(Mandatory=$true)]
        [string]
        $password
  )

function New-AzureMachineName
{
    [string] $username = $env:USERNAME
    $randomChars = 14- $username.Length
    [System.Int64] $min = [System.Math]::Pow(10,$randomChars-1)
    [System.Int64] $Max = [System.Math]::Pow(10,$randomChars)-1
    $result = "$username$(Get-Random -Minimum $min -Maximum $max)"
    return $result
}  


if([string]::IsNullOrWhiteSpace($machineName))
{
  $machineName = New-AzureMachineName
}

# Get the 2012 R2 Images
$images = get-azurevmimage | Where-Object{$_.location -match $location -and $_.label -notmatch 'sql' -and $_.label -notmatch 'RightImage' -and $_.label -match '^windows server 2012 R2'} 
# Get the latest image date
$latestImagePublishedDate = $images | Select-Object -Unique publishedDate | Sort-Object -Property publishedDate -Descending  |  Select-Object -First 1
#get the latest Image
$image = $images.Where{$_.PublishedDate -eq $latestImagePublishedDate.PublishedDate}

$vm = New-AzureQuickVM -Windows -Name $machineName -Password $password -AdminUsername $AdminUserName -EnableWinRMHttp -ImageName $image.ImageName -ServiceName $machineName -Location $location

$zip = &$PSScriptRoot\CreateMySqlProvisionZip.ps1 -xMySqlFolder ((Resolve-Path $PSScriptRoot\..\..).ProviderPath)
Publish-AzureVMDscConfiguration -ConfigurationPath $zip -Force  

$vm = Get-AzureVM -ServiceName $machineName -Name $machineName
$vm | Set-AzureVMDscExtension -ConfigurationDataPath "$PSScriptRoot\..\nodedata.psd1" -ConfigurationArgument @{
    MySQLInstancePackagePath = 'http://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-community-5.6.17.0.msi'
    MySQLInstancePackageName = 'MySQL Installer'
    RootCredential = @{
        UserName = 'administrator'
        Password = 'PrivateSettingRef:RootCredential'
    }
    UserCredential = @{
        UserName = 'mysqluser'
        Password = 'PrivateSettingRef:UserCredential'
    }
} -ConfigurationName 'SQLInstanceInstallationConfiguration' -ConfigurationArchive 'SampleMySqlProvision.ps1.zip'
