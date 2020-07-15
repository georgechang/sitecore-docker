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
		[int] $ShardNumber,
		[switch]$Local
	)


	$scriptContent = "UPDATE __ShardManagement.ShardsGlobal SET ServerName = '$DatabaseServer', DatabaseName = '$DatabaseName' WHERE DatabaseName = 'Placeholder$ShardNumber'"

	if ($Local) {
		$scriptContent = "UPDATE __ShardManagement.ShardsLocal SET ServerName = '$DatabaseServer', DatabaseName = '$DatabaseName'"
	}
	Invoke-Sqlcmd -Database $DatabaseName -ServerInstance $DatabaseServer -Username $DatabaseUserName -Password $DatabasePassword -OutputSqlErrors $true -Query "$scriptContent" -ErrorAction Ignore
}