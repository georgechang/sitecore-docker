$username = $env:DATABASE_USERNAME
$password = $env:DATABASE_PASSWORD
$dbPrefix = $env:DATABASE_PREFIX
$dbServer = $env:DATABASE_SERVER

$variables = @{
	coreUserName            = "coreuser";
	securityUserName        = "securityuser";
	masterUserName          = "masteruser";
	webUserName             = "webuser";
	experienceFormsUserName = "formsuser";
	exmUserName             = "exmmasteruser";
	tasksUserName           = "tasksuser";
}
$variables.add("corePassword", $password)
$variables.add("securityPassword", "$password")
$variables.add("masterPassword", $password)
$variables.add("webPassword", $password)
$variables.add("experienceFormsPassword", $password)
$variables.add("exmPassword", $password)
$variables.add("tasksPassword", $password)

$variables.add("adminPassword", $env:ADMIN_PASSWORD)

Publish-SitecoreDatabases -Path ..\configuration\sc-configuration.json -ResourcesPath ..\resources\sitecore -DatabaseServer $dbServer -DatabasePrefix $dbPrefix -DatabaseUserName $username -DatabasePassword $password -Variables $variables