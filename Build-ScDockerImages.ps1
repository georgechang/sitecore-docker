param(
  $WindowsVersion = "2004",
  $SitecoreVersion = "9.3.0",
  $SolrVersion = "8.5.2",
  $PowerShellVersion = "7.0.1",
  $SqlVersion = "2019-CU4",
  $SqlBuild = "15",
  $TraefikVersion = "2.1.3",
  $Registry = "george.azurecr.io",
  $SitecoreArchive = "Sitecore 9.3.0 rev. 003498 (OnPrem)_single.scwdp.zip",
  $XConnectArchive = "Sitecore 9.3.0 rev. 003498 (OnPrem)_xp0xconnect.scwdp.zip",
  $IdentityArchive = "Sitecore.IdentityServer 4.0.0 rev. 00257 (OnPrem)_identityserver.scwdp.zip",
  $PowerShellArchive = "PowerShell-7.0.1-win-x64.zip",
  $SqlExe = "SQLServer2019-DEV-x64-ENU.exe",
  $JavaVersion = "8u232",
  $JavaUrlVersion = "8u232b09",
  $JavaBaseUrl = "https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u232-b09/OpenJDK8U-jre_",
  $SolrBaseUrl = "https://archive.apache.org/dist/lucene/solr",
  [switch]$Dependencies = $false,
  [switch]$Builder = $false,
  [switch]$PowerShell = $false,
  [switch]$Application = $false
)

$stopwatch = [system.diagnostics.stopwatch]::StartNew()

$buildArgs = @()
$buildArgs += "build"
$buildArgs += "--rm"
$buildArgs += "--isolation=process"

if ($PowerShell) {
  Push-Location .\dependencies\powershell\
  $powershellResourcesPath = ".\resources\$PowerShellVersion"

  if (!(Test-Path $powershellResourcesPath)) {
    Expand-Archive $PSScriptRoot\packages\powershell\$PowerShellVersion\$PowerShellArchive -DestinationPath $powershellResourcesPath -Force
  }

  $powershellBaseBuildArgs = $buildArgs
  $powershellBaseBuildArgs += "-t powershell:nanoserver-$WindowsVersion"
  $powershellBaseBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
  $powershellBaseBuildArgs += "--build-arg PS_PATH=$powershellResourcesPath"
  $powershellBaseBuildArgs += "."
  Start-Process docker -ArgumentList $powershellBaseBuildArgs -NoNewWindow -Wait 
  Pop-Location
}

# build builder image
if ($Builder) {
  Push-Location .\builder\
  $sitecoreResourcesPath = ".\resources\$SitecoreVersion\sitecore"
  $xconnectResourcesPath = ".\resources\$SitecoreVersion\xconnect"
  $identityResourcesPath = ".\resources\$SitecoreVersion\identity"
  
  if (!(Test-Path $sitecoreResourcesPath)) {
    Expand-Archive $PSScriptRoot\packages\sitecore\$SitecoreVersion\$SitecoreArchive -DestinationPath $sitecoreResourcesPath -Force
  }

  if (!(Test-Path $xconnectResourcesPath)) {
    Expand-Archive $PSScriptRoot\packages\sitecore\$SitecoreVersion\$XConnectArchive -DestinationPath $xconnectResourcesPath -Force
  }

  if (!(Test-Path $identityResourcesPath)) {
    Expand-Archive $PSScriptRoot\packages\sitecore\$SitecoreVersion\$IdentityArchive -DestinationPath $identityResourcesPath -Force
  }

  $builderBuildArgs = $buildArgs
  $builderBuildArgs += "-t builder:$SitecoreVersion-$WindowsVersion"
  $builderBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
  $builderBuildArgs += "--build-arg CONFIGURATION_PATH=""./configuration/$SitecoreVersion"""
  $builderBuildArgs += "--build-arg SC_PATH=""$sitecoreResourcesPath"""
  $builderBuildArgs += "--build-arg XC_PATH=""$xconnectResourcesPath"""
  $builderBuildArgs += "--build-arg SI_PATH=""$identityResourcesPath"""
  $builderBuildArgs += "."
  Start-Process docker -ArgumentList $builderBuildArgs -NoNewWindow -Wait 
  Pop-Location
}

# build dependency images
if ($Dependencies) {
  # Solr
  $solrTag = "solr:$SolrVersion-$WindowsVersion"
  $solrBuildArgs = $buildArgs
  $solrBuildArgs += "-t $solrTag"
  $solrBuildArgs += "-t $Registry/$solrTag"
  $solrBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
  $solrBuildArgs += "--build-arg SC_VERSION=$SitecoreVersion"
  $solrBuildArgs += "--build-arg SOLR_VERSION=$SolrVersion"
  $solrBuildArgs += "--build-arg SOLR_BASE_URL=""$SolrBaseUrl"""
  $solrBuildArgs += "--build-arg JAVA_VERSION=$JavaVersion"
  $solrBuildArgs += "--build-arg JAVA_URL_VERSION=$JavaUrlVersion"
  $solrBuildArgs += "--build-arg JAVA_BASE_URL=""$JavaBaseUrl"""
  $solrBuildArgs += "--build-arg CONFIGURATION=""./configuration/$SitecoreVersion"""
  $solrBuildArgs += "."

  Push-Location .\dependencies\solr
  Start-Process docker -ArgumentList $solrBuildArgs -NoNewWindow -Wait
  Pop-Location

  # SQL Server
  Push-Location .\dependencies\mssql
  $sqlResourcesPath = ".\resources\$SqlVersion"
  if (!(Test-Path $sqlResourcesPath)) {
    Start-Process -Wait -FilePath $PSScriptRoot\packages\mssql\$SqlVersion\$SqlExe -ArgumentList /q, /x:$sqlResourcesPath
  }
  
  $sqlTag = "mssql:$SqlVersion-$WindowsVersion"
  $sqlBuildArgs = $buildArgs
  $sqlBuildArgs += "-t $sqlTag"
  $sqlBuildArgs += "-t $Registry/$sqlTag"
  $sqlBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
  $sqlBuildArgs += "--build-arg MSSQL_PATH=""$sqlResourcesPath"""
  $sqlBuildArgs += "--build-arg MSSQL_BUILD=$SqlBuild"
  $sqlBuildArgs += "."
  Write-Host $sqlBuildArgs
  Start-Process docker -ArgumentList $sqlBuildArgs -NoNewWindow -Wait
  Pop-Location

  # Traefik
  $traefikTag = "traefik:$TraefikVersion-$WindowsVersion"
  $traefikBuildArgs = $buildArgs
  $traefikBuildArgs += "-t $traefikTag"
  $traefikBuildArgs += "-t $Registry/$traefikTag"
  $traefikBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
  $traefikBuildArgs += "--build-arg SC_VERSION=$SitecoreVersion"
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
    $applicationBuildArgs += "--build-arg CONFIGURATION=""./configuration/$SitecoreVersion"""
    $applicationBuildArgs += "."
    Write-Host "Building $($directory.FullName)..."
    Push-Location $directory.FullName
    Start-Process docker -ArgumentList $applicationBuildArgs -NoNewWindow -Wait 
    Pop-Location
  }
}

$stopwatch.Stop()
Write-Host "Completed in $($stopwatch.Elapsed)"