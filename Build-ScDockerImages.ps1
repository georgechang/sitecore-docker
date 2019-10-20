$winversion = "1903"
$scversion = "9.2"
$solrversion = "7.5.0"
$registry="george.azurecr.io"

$stopwatch =  [system.diagnostics.stopwatch]::StartNew()

# build dependency images
#Start-Process docker -ArgumentList "build", "--rm", "-t", "solr:$solrversion-$winversion", "-t", "$registry/solr:$solrversion-$winversion", "--build-arg", "SOLRVERSION=$solrversion", "--build-arg", "WINVERSION=$winversion", "-f", ".\dependencies\solr\Dockerfile", "." -NoNewWindow -Wait
Start-Process docker -ArgumentList "build", "--rm", "-t", "mssql:2017-$winversion", "-t", "$registry/mssql:2017-$winversion", "--build-arg", "WINVERSION=$winversion", "-f", ".\dependencies\mssql\Dockerfile", "." -NoNewWindow -Wait

# build base images
#Get-ChildItem .\base\ -Directory | Where-Object { Test-Path "$($_.FullName)\Dockerfile" } | ForEach-Object { Start-Process docker -ArgumentList "build", "--rm", "-t", "scbase-$($_.Name):$winversion", "--build-arg", "WINVERSION=$winversion", "-f", ".\base\$($_.Name)\Dockerfile", "." -NoNewWindow -Wait }

# build application images
#Get-ChildItem .\application\ -Directory | Where-Object { Test-Path "$($_.FullName)\Dockerfile" } | ForEach-Object { Start-Process docker -ArgumentList "build", "--rm", "-t", "$($_.Name):$scversion-$winversion", "-t", "$registry/$($_.Name):$scversion-$winversion", "--build-arg", "WINVERSION=$winversion", "--build-arg", "SCVERSION=$scversion", "-f", ".\application\$($_.Name)\Dockerfile", "."  -NoNewWindow -Wait }

$stopwatch.Stop()
Write-Host "Completed in $($stopwatch.Elapsed)"