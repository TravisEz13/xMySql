Function Update-AzureDemoMySqlVm
{
[cmdletbinding()]
Param(
    [Parameter(Mandatory=$true)]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVMRoleListContext]
    $vm,
    [Parameter(Mandatory=$true)]
    [string]
    $password,

    [ValidateSet('Provision','Install')]
    $configuration


    )    

    # Create Zip
    Write-Verbose -Message 'Creating Zip ....' -Verbose
    $zip = New-ConfigurationZip -Configuration $configuration
    $zipName = split-path -Leaf $zip

    # Publish Zip
    Write-Verbose -Message 'Publishing Zip ....' -Verbose
    Publish-AzureVMDscConfiguration -ConfigurationPath $zip -Force  -Verbose

    # Create Parameters
    $securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
    $administrator  = New-Object System.Management.Automation.PSCredential 'administrator',$securePassword
    $user           = New-Object System.Management.Automation.PSCredential 'mysqlUser',$securePassword

    $ConfigurationArguments = @{
        MySQLInstancePackagePath = 'http://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-community-5.6.17.0.msi'
        MySQLInstancePackageName = 'MySQL Installer'
        RootCredential           = $administrator
    }

    if($configuration -ieq 'Provision')
    {
        $ConfigurationArguments.Add('UserCredential', $user)
    }

    # Open Port
    $port = $vm |Get-AzureEndpoint -Name MySql
    if(!$port)
    {
        Add-AzureEndpoint -LocalPort 3306 -PublicPort 3306 -Name MySql -Protocol tcp -VM $vm
    }

    # Set Extension
    Write-Verbose -Message 'Setting Extension ....' -Verbose
    $vm | Set-AzureVMDscExtension `
         -ConfigurationDataPath "$PSScriptRoot\..\nodedata.psd1"`
         -ConfigurationArgument $configurationArguments `
         -ConfigurationName 'SQLInstanceInstallationConfiguration' `
         -ConfigurationArchive $zipName -Verbose

    # Update VM
    Write-Verbose -Message 'Updating VM ....' -Verbose
    $vm|Update-AzureVM

    Write-Verbose -Message 'Done!' -Verbose
}

Function New-AzureDemoVm
{
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
    return $vm
}


function Get-AzureDemoVm
{
    return Get-AzureVm | Where-Object{$_.Name -like 'tplunk*'} | Out-GridView -Title 'Select VM' -OutputMode Single
}

<#
.Synopsis
    Installs the WinRM certification of the given VM to the local store
#>
function Install-AzureVMWinRMCertificate
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVMRoleContext] $VM
    )

    $certificateFile = $null

    try 
    {
        $thumbprint = $VM.VM.DefaultWinRmCertificateThumbprint

        if (Get-ChildItem Cert:\LocalMachine\Root\$thumbprint -ErrorAction Ignore)
        {
            Write-Verbose "Certificate $thumbprint is already installed."
            return
        }

        $certificate = Get-AzureCertificate -ServiceName $VM.ServiceName -Thumbprint $thumbprint -ThumbprintAlgorithm sha1

        $certificateFile = [IO.Path]::GetTempFileName()
        $certificate.Data | Out-File $certificateFile

        $location = 'Cert:\LocalMachine\Root'

        Write-Verbose "Installing certificate $thumbprint to $location..."

        Import-Certificate -FilePath $certificateFile -CertStoreLocation $location
    }
    finally
    {
        if ($certificateFile)
        {
            Remove-Item -Force $certificateFile -ErrorAction Ignore
        }
    }
}

<#
.Synopsis
    Creates a PS remoting session to the given VM
#>
function New-AzureVMPSSession
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1)]
            [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVMRoleContext] $VM,

        [Parameter(Mandatory=$true, Position=2)]
            [System.Management.Automation.PSCredential] $Credential
    )

    $connectionUri = Get-AzureWinRMUri -Name $vm.Name -ServiceName $vm.ServiceName

    New-PSSession -ConnectionUri $connectionUri -Credential $Credential
}

function New-ConfigurationZip
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [Object]
        $Configuration
    )
    
    
    if($configuration -ieq 'Provision')
    {
        $zip = &$PSScriptRoot\CreateMySqlProvisionZip.ps1 -xMySqlFolder ((Resolve-Path $PSScriptRoot\..\..).ProviderPath)
    }
    else
    {
        $zip = &$PSScriptRoot\CreateMySqlInstallZip.ps1 -xMySqlFolder ((Resolve-Path $PSScriptRoot\..\..).ProviderPath)
    }
    return $zip
}
