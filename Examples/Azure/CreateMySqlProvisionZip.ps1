param(
  [string] $xMySqlFolder
)

# Create Temp folders
$tempFolder = "$env:temp\$([guid]::newguid())"
$zipFolder = "$env:temp\$([guid]::newguid())"
if(!(test-path $tempfolder))
{
  md $tempFolder > $null
}

if(!(test-path $zipfolder))
{
  md $zipFolder > $null
}

# clone and copy files to temp folders
git clone https://github.com/PowerShell/xPSDesiredStateConfiguration.git "$tempFolder\xPsDesiredStateConfiguration" 2> $null
Remove-Item -Recurse -Force "$tempFolder\xPsDesiredStateConfiguration\.git"
copy-item $xMySqlFolder "$tempFolder\xMySql" -recurse
Remove-Item -Recurse -Force "$tempFolder\xMySql\.git"
copy-item "$xMySqlFolder\Examples\Sample_MySQL_Provision.ps1" $tempFolder

# Zip Folder
$zipFile = "$zipFolder\Sample_MySQL_Provision.ps1.zip"
Add-Type -assemblyname System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempFolder, $zipFile)
Remove-Item -Recurse -Force $tempFolder

# Publish arftifact if in AppVeyor
if((Get-Command -Name Push-AppveyorArtifact -ErrorAction SilentlyContinue))
{
  Push-AppveyorArtifact $zipFile
}
else
{
  Write-Verbose -message "Not running in appveyor, zipfile is at:  $zipfile" -verbose
}
