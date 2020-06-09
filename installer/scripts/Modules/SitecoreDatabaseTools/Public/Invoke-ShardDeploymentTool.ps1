function Invoke-ShardDeploymentTool {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[string]$Path,
		[Parameter(Mandatory=$true)]
		[string]$DatabaseServer,
		[Parameter(Mandatory=$true)]
		[string]$DatabaseUserName,
		[Parameter(Mandatory=$true)]
		[string]$DatabasePassword,
		[Parameter(Mandatory=$true)]
		[string]$DatabasePrefix,
		[Parameter(Mandatory=$true)]
		[int]$ShardCount,
		[string]$Dacpac = "Sitecore.Xdb.Collection.Database.Sql.dacpac"
	)

	$arguments = @()
	$arguments += "/operation ""create"""
	$arguments += "/connectionstring ""Data Source=$DatabaseServer;User Id=$DatabaseUserName;Password=$DatabasePassword;Integrated Security=false"""
	$arguments += "/dbedition ""Standard"""
	$arguments += "/shardMapManagerDatabaseName ""$($DatabasePrefix)Xdb.Collection.ShardMapManager"""
	$arguments += "/shardMapNames ""ContactIdShardMap,DeviceProfileIdShardMap,ContactIdentifiersIndexShardMap"""
	$arguments += "/shardnumber ""$ShardCount"""
	$arguments += "/shardnameprefix ""$($DatabasePrefix)Xdb.Collection.Shard"""
	$arguments += "/shardnamesuffix """""
	$arguments += "/dacpac ""$Dacpac"""

	Push-Location $Path
	Start-Process .\Sitecore.Xdb.Collection.Database.SqlShardingDeploymentTool.exe -ArgumentList $arguments -NoNewWindow -Wait
	Pop-Location
}