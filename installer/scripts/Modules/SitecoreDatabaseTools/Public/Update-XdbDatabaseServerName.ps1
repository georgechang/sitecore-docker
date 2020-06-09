function Update-XdbDatabaseServerName {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]$DatabaseServer,
		[Parameter(Mandatory = $true)]
		[string]$DatabaseUserName,
		[Parameter(Mandatory = $true)]
		[string]$DatabasePassword,
		[Parameter(Mandatory = $true)]
		[string]$DatabaseName,
		[Parameter(Mandatory = $true)]
		[string]$NewDatabaseServer
	)

	$scriptContentLocal = "UPDATE __ShardManagement.ShardsLocal SET ServerName = '$NewDatabaseServer'"
	$scriptContentGlobal = "UPDATE __ShardManagement.ShardsGlobal SET ServerName = '$NewDatabaseServer'"
	Invoke-Sqlcmd -Database $DatabaseName -ServerInstance $DatabaseServer -Username $DatabaseUserName -Password $DatabasePassword -OutputSqlErrors $true -Query $scriptContentLocal -Variable $sqlcommandVariables -ErrorAction Ignore
	Invoke-Sqlcmd -Database $DatabaseName -ServerInstance $DatabaseServer -Username $DatabaseUserName -Password $DatabasePassword -OutputSqlErrors $true -Query $scriptContentGlobal -Variable $sqlcommandVariables -ErrorAction Ignore
}