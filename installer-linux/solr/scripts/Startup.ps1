#!/usr/bin/env pwsh
Write-Host "Updating configs..."
& $PSScriptRoot/Update-SolrConfiguration.ps1 -ConfigPath "/tmp/solr/server/solr/configsets/_default" -SolrUrl $env:SOLR_URL
Write-Host "Add Sitecore collections..."
& $PSScriptRoot/Initialize-SolrCollections.ps1 -JsonPath "$PSScriptRoot/../configuration/sc-configuration.json" -SolrUrl $env:SOLR_URL
Write-Host "Add xDB collections..."
& $PSScriptRoot/Initialize-SolrCollections.ps1 -JsonPath "$PSScriptRoot/../configuration/xdb-configuration.json" -SolrUrl $env:SOLR_URL
Write-Host "Done!"