function Publish-SitecoreDatabases {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[string]$Path,
		[string]$ResourcesPath = $pwd,
		[string]$SqlPackageExePath = $pwd,
		[Parameter(Mandatory=$true)]
		[string]$DatabaseServer,
		[string]$DatabasePrefix,
		[string]$DatabaseUserName,
		[string]$DatabasePassword,
		[hashtable]$Variables
	)

	Write-Debug "Fetching configuration from $Path..."
	$configuration = Get-Content $Path -Raw | ConvertFrom-Json

	foreach ($database in $configuration.databases)
	{
		$databaseName = "$($DatabasePrefix)$($database.name)";
		Write-Host "Updating $($databaseName)..."
		Write-Debug "Prescripts: $($database.prescripts.length)"
		if ($database.prescripts.length -gt 0)
		{
			$database.prescripts | % { Invoke-DatabaseScript $_ -ResourcesPath $ResourcesPath -DatabaseServer $DatabaseServer -DatabaseName $databaseName -DatabaseUserName $DatabaseUserName -DatabasePassword $DatabasePassword -Variables $variables }
		}
		if ($null -ne $database.dacpac -and (Test-Path "$(Join-Path $ResourcesPath -ChildPath $database.dacpac)"))
		{
			Write-Debug "SourceFile: $($database.dacpac)"
			$arguments = @()
			$arguments += "/SourceFile:""$(Join-Path $ResourcesPath -ChildPath $database.dacpac)"""
			$arguments += "/Action:Publish"
			$arguments += "/TargetServerName:""$DatabaseServer"""
			$arguments += "/TargetDatabaseName:""$($databaseName)"""
			$arguments += "/TargetUser:""$DatabaseUserName"""
			$arguments += "/TargetPassword:""$DatabasePassword"""
			$arguments += "/p:AllowIncompatiblePlatform=true"
			Push-Location $SqlPackageExePath
			Start-Process SqlPackage.exe -ArgumentList $arguments -NoNewWindow -Wait
			Pop-Location
		}
		Write-Debug "Postscripts: $($database.postscripts.length)"
		if ($database.postscripts.length -gt 0)
		{
			$database.postscripts | % { Invoke-DatabaseScript $_ -ResourcesPath $ResourcesPath -DatabaseServer $DatabaseServer -DatabaseName $databaseName -DatabaseUserName $DatabaseUserName -DatabasePassword $DatabasePassword -Variables $variables }
		}
	}
}


# $variables = "ServerName='$databaseServerFqdn'", "Shard0DbName='$($dbPrefix)_xdb.collection.shard0'", "Shard1DbName='$($dbPrefix)_xdb.collection.shard1'"
# Invoke-Sqlcmd -Database "$($dbPrefix)_xdb.collection.shardmapmanager" -ServerInstance $databaseServerFqdn -Username $username -Password $password -OutputSqlErrors $true -Variable $variables -InputFile .\smm_azure.sql
# Invoke-Sqlcmd -Database "$($dbPrefix)_xdb.collection.shard0" -ServerInstance $databaseServerFqdn -Username $username -Password $password -OutputSqlErrors $true -Variable $variables -InputFile .\shard0_azure.sql
# Invoke-Sqlcmd -Database "$($dbPrefix)_xdb.collection.shard1" -ServerInstance $databaseServerFqdn -Username $username -Password $password -OutputSqlErrors $true -Variable $variables -InputFile .\shard1_azure.sql

# Invoke-Sqlcmd -Database "$($dbPrefix)_xdb.collection.shardmapmanager" -ServerInstance $databaseServerFqdn -Username $username -Password $password -OutputSqlErrors $true -InputFile -Variable $variables .\shard1_azure.sql