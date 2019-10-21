param(
	[switch]$Dependencies = $false,
	[switch]$Common = $false,
	[switch]$Application = $false
)

$winversion = "1903"
$scversion = "9.2"
$solrversion = "7.5.0"
$registry = "george.azurecr.io"
$scarchive = "Sitecore-9.2.0.zip"
$xcarchive = "xConnect-9.2.0.zip"
$siarchive = "Identity-3.0.0.zip"

$stopwatch = [system.diagnostics.stopwatch]::StartNew()

# build dependency images
if ($Dependencies) {
	Push-Location .\dependencies\solr
	Start-Process docker -ArgumentList "build", "--rm", "-t", "solr:$solrversion-$winversion", "-t", "$registry/solr:$solrversion-$winversion", "--build-arg", "SOLR_VERSION=$solrversion", "--build-arg", "WIN_VERSION=$winversion", "." -NoNewWindow -Wait
	Pop-Location

	$SQLVersion = "RTM"
	#$SQLVersion = "CU17"
	# 11 $CUUrl = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2018/09/sqlserver2017-kb4462262-x64_c974e2962d83a909c08bbe7a48c8c022e9076f58.exe"
	$CUUrl = "https://download.microsoft.com/download/C/4/F/C4F908C9-98ED-4E5F-88D5-7D6A5004AEBD/SQLServer2017-KB4515579-x64.exe"

	Push-Location .\dependencies\mssql
	Start-Process docker -ArgumentList "build", "--rm", "-t", "mssql:2017-$SQLVersion-$winversion", "-t", "$registry/mssql:2017-$SQLVersion-$winversion", "--build-arg", "WIN_VERSION=$winversion", "--build-arg", "CU=$CUUrl", "." -NoNewWindow -Wait
	Pop-Location
}

# build common image
if ($Common) {
	Push-Location .\common\
	Start-Process docker -ArgumentList "build", "--rm", "-t", "common:$winversion", "--build-arg", "WIN_VERSION=$winversion", "--build-arg", "SC_ARCHIVE=$scarchive", "--build-arg", "XC_ARCHIVE=$xcarchive", "--build-arg", "SI_ARCHIVE=$siarchive", "."  -NoNewWindow -Wait 
	Pop-Location
}

# build application images
if ($Application) {
	$directories = Get-ChildItem .\application\ -Directory | Where-Object { Test-Path "$($_.FullName)\Dockerfile" }
	foreach ($directory in $directories) {
		Write-Host "Building $($directory.FullName)..."
		Push-Location $directory.FullName
		Start-Process docker -ArgumentList "build", "--rm", "-t", "$($directory.Name):$scversion-$winversion", "-t", "$registry/$($directory.Name):$scversion-$winversion", "--build-arg", "WIN_VERSION=$winversion", "."  -NoNewWindow -Wait 
		Pop-Location
	}
}

$stopwatch.Stop()
Write-Host "Completed in $($stopwatch.Elapsed)"