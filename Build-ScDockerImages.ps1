param(
  $WindowsVersion = "1903",
  $SitecoreVersion = "9.3",
  $SolrVersion = "8.3.0",
  $Registry = "george.azurecr.io",
  $SitecoreArchive = "Sitecore-9.3.0.zip",
  $XConnectArchive = "xConnect-9.3.0.zip",
  $IdentityArchive = "Identity-4.0.0.zip",
  [switch]$Dependencies = $false,
  [switch]$Common = $false,
  [switch]$Application = $false
)

$stopwatch = [system.diagnostics.stopwatch]::StartNew()

# build common image
if ($Common) {
  Push-Location .\common\
  Start-Process docker -ArgumentList "build", "--rm", "-t", "common:$WindowsVersion", "--build-arg", "WIN_VERSION=$WindowsVersion", "--build-arg", "SC_ARCHIVE=$SitecoreArchive", "--build-arg", "XC_ARCHIVE=$XConnectArchive", "--build-arg", "SI_ARCHIVE=$IdentityArchive", "."  -NoNewWindow -Wait 
  Pop-Location
}

# build dependency images
if ($Dependencies) {
  Push-Location .\dependencies\solr
  Start-Process docker -ArgumentList "build", "--rm", "-t", "solr:$SolrVersion-$WindowsVersion", "-t", "$Registry/solr:$SolrVersion-$WindowsVersion", "--build-arg", "SOLR_VERSION=$SolrVersion", "--build-arg", "WIN_VERSION=$WindowsVersion", "." -NoNewWindow -Wait
  Pop-Location

  $SQLVersion = "RTM"
  #$SQLVersion = "CU17"
  # 11 $CUUrl = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2018/09/sqlserver2017-kb4462262-x64_c974e2962d83a909c08bbe7a48c8c022e9076f58.exe"
  $CUUrl = "https://download.microsoft.com/download/C/4/F/C4F908C9-98ED-4E5F-88D5-7D6A5004AEBD/SQLServer2017-KB4515579-x64.exe"

  Push-Location .\dependencies\mssql
  Start-Process docker -ArgumentList "build", "--rm", "-t", "mssql:2017-$SQLVersion-$WindowsVersion", "-t", "$Registry/mssql:2017-$SQLVersion-$WindowsVersion", "--build-arg", "WIN_VERSION=$WindowsVersion", "--build-arg", "CU=$CUUrl", "." -NoNewWindow -Wait
  Pop-Location
}

# build application images
if ($Application) {
  $directories = Get-ChildItem .\application\ -Directory | Where-Object { Test-Path "$($_.FullName)\Dockerfile" }
  foreach ($directory in $directories) {
    Write-Host "Building $($directory.FullName)..."
    Push-Location $directory.FullName
    Start-Process docker -ArgumentList "build", "--rm", "-t", "$($directory.Name):$SitecoreVersion-$WindowsVersion", "-t", "$Registry/$($directory.Name):$SitecoreVersion-$WindowsVersion", "--build-arg", "WIN_VERSION=$WindowsVersion", "--build-arg", "SC_VERSION=$SitecoreVersion", "."  -NoNewWindow -Wait 
    Pop-Location
  }
}

$stopwatch.Stop()
Write-Host "Completed in $($stopwatch.Elapsed)"