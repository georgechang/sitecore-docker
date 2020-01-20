$json = Get-Content "/configuration/configuration.json" | ConvertFrom-Json

foreach ($core in $json.cores) {
	if (-not (Test-Path "/solr/server/solr/$core")) {
		Copy-Item "/solr/server/solr/configsets/_default" "/solr/server/solr/$core"
	}
}