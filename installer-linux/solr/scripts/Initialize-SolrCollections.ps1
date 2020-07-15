param(
	# The path to the JSON config file
	[Parameter(Mandatory = $true)]
	[string]$JsonPath,
	# The URL to the Solr instance
	[Parameter(Mandatory = $true)]
	[string]$SolrUrl,
	[int]$ReplicationFactor = 2
)

$jsonContent = Get-Content -Path $JsonPath | Out-String | ConvertFrom-Json

foreach ($index in $jsonContent.indexes) {
	Invoke-RestMethod "$SolrUrl/api/c" -ContentType "application/json" -Body "{ create:{ name: '$index', config: 'sitecore', numShards: 1, replicationFactor: $ReplicationFactor } }" -Method Post
}