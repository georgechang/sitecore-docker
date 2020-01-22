$json = Get-Content "/configuration/configuration.json" | ConvertFrom-Json

foreach ($core in $json.cores) {
	if (-not (Test-Path "/solr/server/solr/mydata/$core")) {
		Write-Host "Core '$core' not found, creating..."
		Copy-Item -Recurse "/solr/server/solr/configsets/_default" "/solr/server/solr/mydata/$core"
		Write-Host "Core '$core' created."
	}
	else {
		Write-Host "Core '$core' found, skipping..."
	}
}

# https://prft.sc/sitecore/admin/PopulateManagedSchema.aspx?indexes=all

Invoke-Expression -Command "/solr/bin/solr.cmd start -f -t ./mydata -p 8983" 