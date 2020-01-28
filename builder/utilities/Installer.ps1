Install-Module sqlserver -Confirm:$false -Force
Import-Module sqlserver
Install-Module mashups -Confirm:$false -Force
Import-Module mashups

$dbPrefix = $env:DATABASE_PREFIX
$dbServer = $env:DATABASE_SERVER
$shards = 2

$username = $env:DATABASE_USERNAME
$password = $env:DATABASE_PASSWORD

$variables = @{
	automationUserName       = "automationuser";
	messagingUserName        = "messaginguser";
	poolsUserName            = "poolsuser";
	processingengineUserName = "processingengineuser";
	referenceDataUserName    = "referencedatauser";
	reportingUserName        = "reportinguser";
	collectionUserName       = "collectionuser";
	coreUserName             = "coreuser";
	securityUserName         = "securityuser";
	masterUserName           = "masteruser";
	webUserName              = "webuser";
	experienceFormsUserName  = "formsuser";
	exmUserName              = "exmmasteruser";
	tasksUserName            = "tasksuser";
}
$variables.add("automationPassword", $password)
$variables.add("messagingPassword", "$password")
$variables.add("poolsPassword", $password)
$variables.add("processingenginePassword", $password)
$variables.add("referenceDataPassword", $password)
$variables.add("reportingPassword", $password)
$variables.add("collectionPassword", $password)
$variables.add("corePassword", $password)
$variables.add("securityPassword", "$password")
$variables.add("masterPassword", $password)
$variables.add("webPassword", $password)
$variables.add("experienceFormsPassword", $password)
$variables.add("exmPassword", $password)
$variables.add("tasksPassword", $password)

$variables.add("adminPassword", "b")

Publish-SitecoreDatabases -Path /configuration/xdb-databases.json -ResourcesPath /resources/xconnect -DatabaseServer $dbServer -DatabasePrefix $dbPrefix -DatabaseUserName $username -DatabasePassword $password -Variables $variables

Invoke-ShardDeploymentTool -Path /resources/xConnect/Content/Website/App_Data/collectiondeployment -DatabaseServer $dbServer -DatabasePrefix $dbPrefix -DatabaseUserName $username -DatabasePassword $password -ShardCount $shards

Invoke-Sqlcmd -Query "CREATE LOGIN $($variables.collectionUserName) WITH PASSWORD = '$($variables.collectionPassword)'" -ServerInstance $dbServer -Username $username -Password $password -Database "master" -ErrorAction SilentlyContinue
Invoke-Sqlcmd -Query "EXEC sp_addrolemember 'db_datareader', '$($variables.collectionUserName)'; EXEC sp_addrolemember 'db_datawriter', '$($variables.collectionUserName)';" -ServerInstance $dbServer -Username $username -Password $password -Database "master" -ErrorAction SilentlyContinue
Invoke-Sqlcmd -Query "CREATE USER $($variables.collectionUserName) FROM LOGIN $($variables.collectionUserName) GRANT SELECT ON SCHEMA :: __ShardManagement TO [$($variables.collectionUserName)] GRANT EXECUTE ON SCHEMA :: __ShardManagement TO [$($variables.collectionUserName)]" -ServerInstance $dbServer -Username $username -Password $password -Database "$($dbPrefix)Xdb.Collection.ShardMapManager"
for ($i = 0; $i -lt $shards; $i++) {
	Invoke-Sqlcmd -Query "CREATE USER $($variables.collectionUserName) FROM LOGIN $($variables.collectionUserName) EXEC [xdb_collection].[GrantLeastPrivilege] @UserName = '$($variables.collectionUserName)'" -ServerInstance $dbServer -Username $username -Password $password -Database "$($dbPrefix)Xdb.Collection.Shard$i"
}

Publish-SitecoreDatabases -Path /configuration/sc-databases.json -ResourcesPath /resources/sitecore -DatabaseServer $dbServer -DatabasePrefix $dbPrefix -DatabaseUserName $username -DatabasePassword $password -Variables $variables