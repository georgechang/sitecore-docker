Get-ChildItem "/solr/server/solr/mydata" -Recurse -Filter write.lock | Remove-Item | Out-Null

& C:\solr\bin\solr.cmd start -f -t ./mydata -p 8983

# $json = Get-Content "/configuration/configuration.json" | ConvertFrom-Json
# foreach ($core in $json.cores) {
# 	if (-not (Test-Path "/solr/server/solr/mydata/$core")) {
# 		Write-Host "Core '$core' not found, creating..."
# 		& C:\solr\bin\solr.cmd create_core -c $core -p 8983
# 		#Copy-Item -Recurse "/solr/server/solr/configsets/_default" "/solr/server/solr/mydata/$core"
# 		Write-Host "Core '$core' created."
# 	}
# 	else {
# 		Write-Host "Core '$core' found, skipping..."
# 	}
# }
# https://prft.sc/sitecore/admin/PopulateManagedSchema.aspx?indexes=all