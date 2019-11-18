$DatabaseServer = $env:DB_SERVER
$DatabasePrefix = $env:DB_PREFIX
$DatabaseUserName = $env:DB_USERNAME
$DatabasePassword = $env:DB_PASSWORD

$xConnectVariables = @{
	automationUserName       = "automationuser";
	messagingUserName        = "messaginguser";
	poolsUserName            = "poolsuser";
	processingengineUserName = "processingengineuser";
	referenceDataUserName    = "referencedatauser";
	reportingUserName        = "reportinguser";
	collectionUserName       = "collectionuser";
}
$xConnectVariables.add("automationPassword", $password)
$xConnectVariables.add("messagingPassword", "$password")
$xConnectVariables.add("poolsPassword", $password)
$xConnectVariables.add("processingenginePassword", $password)
$xConnectVariables.add("referenceDataPassword", $password)
$xConnectVariables.add("reportingPassword", $password)
$xConnectVariables.add("collectionPassword", $password)

$sitecoreVariables = @{
	coreUserName            = "coreuser";
	securityUserName        = "securityuser";
	masterUserName          = "masteruser";
	webUserName             = "webuser";
	experienceFormsUserName = "formsuser";
	exmUserName             = "exmmasteruser";
	processingTasksUserName = "tasksuser";
}
$sitecoreVariables.add("corePassword", $password)
$sitecoreVariables.add("securityPassword", "$password")
$sitecoreVariables.add("masterPassword", $password)
$sitecoreVariables.add("webPassword", $password)
$sitecoreVariables.add("experienceFormsPassword", $password)
$sitecoreVariables.add("exmPassword", $password)
$sitecoreVariables.add("processingTasksPassword", $password)

$sitecoreVariables.add("adminPassword", "b")

Publish-SitecoreDatabases -Path ..\configuration\xp0-server-xdb-configuration.json -ResourcesPath ..\resources\xConnect -DatabaseServer $DatabaseServer -DatabasePrefix $DatabasePrefix -DatabaseUserName $DatabaseUserName -DatabasePassword $DatabasePassword -Variables $xConnectVariables
Invoke-ShardDeploymentTool -Path ..\resources\xConnect\collectiondeployment -DatabaseServer $DatabaseServer -DatabasePrefix $DatabasePrefix -DatabaseUserName $DatabaseUserName -DatabasePassword $DatabasePassword -ShardCount 2

Publish-SitecoreDatabases -Path ..\configuration\xp0-server-sitecore-configuration.json -ResourcesPath ..\resources\Sitecore -DatabaseServer $DatabaseServer -DatabasePrefix $DatabasePrefix -DatabaseUserName $DatabaseUserName -DatabasePassword $DatabasePassword -Variables $sitecoreVariables