$username = $env:DATABASE_USERNAME
$password = $env:DATABASE_PASSWORD
$dbPrefix = $env:DATABASE_PREFIX
$dbServer = $env:DATABASE_SERVER
$shardCount = $env:SHARD_COUNT

$variables = @{
	automationUserName       = "automationuser";
	messagingUserName        = "messaginguser";
	poolsUserName            = "poolsuser";
	processingengineUserName = "processingengineuser";
	referenceDataUserName    = "referencedatauser";
	reportingUserName        = "reportinguser";
	collectionUserName       = "collectionuser";
}

$variables.add("automationPassword", $automationPassword ?? $password)
$variables.add("messagingPassword", $messagingPassword ?? $password)
$variables.add("poolsPassword", $poolsPassword ?? $password)
$variables.add("processingEnginePassword", $processingEnginePassword ?? $password)
$variables.add("referenceDataPassword", $referenceDataPassword ?? $password)
$variables.add("reportingPassword", $reportingPassword ?? $password)
$variables.add("collectionPassword", $collectionPassword ?? $password)

Publish-SitecoreDatabases -Path ..\configuration\xdb-configuration.json -ResourcesPath ..\resources\xconnect -DatabaseServer $dbServer -DatabasePrefix $dbPrefix -DatabaseUserName $username -DatabasePassword $password -Variables $variables

Invoke-ShardDeploymentTool -Path ..\resources\xconnect\Content\Website\App_Data\collectiondeployment -DatabaseServer $dbServer -DatabasePrefix $dbPrefix -DatabaseUserName $username -DatabasePassword $password -ShardCount $shardCount

Invoke-Sqlcmd -Query "CREATE LOGIN $($variables.collectionUserName) WITH PASSWORD = '$($variables.collectionPassword)'" -ServerInstance $dbServer -Username $username -Password $password -Database "master" -ErrorAction SilentlyContinue
Invoke-Sqlcmd -Query "EXEC sp_addrolemember 'db_datareader', '$($variables.collectionUserName)'; EXEC sp_addrolemember 'db_datawriter', '$($variables.collectionUserName)';" -ServerInstance $dbServer -Username $username -Password $password -Database "master" -ErrorAction SilentlyContinue
Invoke-Sqlcmd -Query "CREATE USER $($variables.collectionUserName) FROM LOGIN $($variables.collectionUserName) GRANT SELECT ON SCHEMA :: __ShardManagement TO [$($variables.collectionUserName)] GRANT EXECUTE ON SCHEMA :: __ShardManagement TO [$($variables.collectionUserName)]" -ServerInstance $dbServer -Username $username -Password $password -Database "$($dbPrefix)Xdb.Collection.ShardMapManager"
for ($i = 0; $i -lt $shardCount; $i++) {
	Invoke-Sqlcmd -Query "CREATE USER $($variables.collectionUserName) FROM LOGIN $($variables.collectionUserName) EXEC [xdb_collection].[GrantLeastPrivilege] @UserName = '$($variables.collectionUserName)'" -ServerInstance $dbServer -Username $username -Password $password -Database "$($dbPrefix)Xdb.Collection.Shard$i"
}