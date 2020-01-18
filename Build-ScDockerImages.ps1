param(
  $WindowsVersion = "1903",
  $SitecoreVersion = "9.3",
  $SolrVersion = "8.3.0",
  $Registry = "george.azurecr.io",
  $SitecoreArchive = "./packages/9.3/Sitecore-9.3.0.zip",
  $XConnectArchive = "./packages/9.3/xConnect-9.3.0.zip",
  $IdentityArchive = "./packages/9.3/Identity-4.0.0.zip",
  [switch]$Dependencies = $false,
  [switch]$Common = $false,
  [switch]$Application = $false
)

$stopwatch = [system.diagnostics.stopwatch]::StartNew()

$buildArgs = @()
$buildArgs += "build"
$buildArgs += "--rm"
$buildArgs += "--isolation=process"

# build common image
if ($Common) {
  $commonBuildArgs = $buildArgs
  $commonBuildArgs += "-t common:$SitecoreVersion-$WindowsVersion"
  $commonBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
  $commonBuildArgs += "--build-arg SC_ARCHIVE=$SitecoreArchive"
  $commonBuildArgs += "--build-arg XC_ARCHIVE=$XConnectArchive"
  $commonBuildArgs += "--build-arg SI_ARCHIVE=$IdentityArchive"
  $commonBuildArgs += "--no-cache"
  $commonBuildArgs += "."
  Push-Location .\common\
  Start-Process docker -ArgumentList $commonBuildArgs -NoNewWindow -Wait 
  Pop-Location
}

# build dependency images
if ($Dependencies) {
  $solrTag = "solr:$SolrVersion-$WindowsVersion"
  $solrBuildArgs = $buildArgs
  $solrBuildArgs += "-t $solrTag"
  $solrBuildArgs += "-t $Registry/$solrTag"
  $solrBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
  $solrBuildArgs += "--build-arg SOLR_VERSION=$SolrVersion"
  $solrBuildArgs += "."
  Push-Location .\dependencies\solr
  Start-Process docker -ArgumentList $solrBuildArgs -NoNewWindow -Wait
  Pop-Location

  $SQLVersion = "RTM"
  #$SQLVersion = "CU17"
  # 11 $CUUrl = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2018/09/sqlserver2017-kb4462262-x64_c974e2962d83a909c08bbe7a48c8c022e9076f58.exe"
  $CUUrl = "https://download.microsoft.com/download/C/4/F/C4F908C9-98ED-4E5F-88D5-7D6A5004AEBD/SQLServer2017-KB4515579-x64.exe"
  $sqlTag = "mssql:2017-$SQLVersion-$WindowsVersion"
  $sqlBuildArgs = $buildArgs
  $sqlBuildArgs += "-t $sqlTag"
  $sqlBuildArgs += "-t $Registry/$sqlTag"
  $sqlBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
  $sqlBuildArgs += "--build-arg CU=$CUUrl"
  $sqlBuildArgs += "."
  Push-Location .\dependencies\mssql
  Start-Process docker -ArgumentList $sqlBuildArgs -NoNewWindow -Wait
  Pop-Location

  $TraefikVersion = "2.1.2"
  $traefikTag = "traefik:$WindowsVersion"
  $traefikBuildArgs = $buildArgs
  $traefikBuildArgs += "-t $traefikTag"
  $traefikBuildArgs += "-t $Registry/$traefikTag"
  $traefikBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
  $traefikBuildArgs += "--build-arg TRAEFIK_VERSION=$TraefikVersion"
  $traefikBuildArgs += "."
  Push-Location .\dependencies\traefik
  Start-Process docker -ArgumentList $traefikBuildArgs -NoNewWindow -Wait
  Pop-Location
}

# build application images
if ($Application) {
  $directories = Get-ChildItem .\application\ -Directory | Where-Object { Test-Path "$($_.FullName)\Dockerfile" }
  foreach ($directory in $directories) {
    $applicationTag = "$($directory.Name):$SitecoreVersion-$WindowsVersion"
    $applicationBuildArgs = $buildArgs
    $applicationBuildArgs += "-t $applicationTag"
    $applicationBuildArgs += "-t $Registry/$applicationTag"
    $applicationBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
    $applicationBuildArgs += "--build-arg SC_VERSION=$SitecoreVersion"
    $applicationBuildArgs += "."
    Write-Host "Building $($directory.FullName)..."
    Push-Location $directory.FullName
    Start-Process docker -ArgumentList $applicationBuildArgs -NoNewWindow -Wait 
    Pop-Location
  }
}

$stopwatch.Stop()
Write-Host "Completed in $($stopwatch.Elapsed)"