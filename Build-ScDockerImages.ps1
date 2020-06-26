param(
  $WindowsVersion = "2004",
  $SitecoreVersion = "9.3.0",
  $SolrVersion = "8.5.2",
  $PowerShellVersion = "7.0.2",
  $SqlVersion = "2019-CU5",
  $SqlBuild = "15",
  $TraefikVersion = "latest",
  $Registry = "george.azurecr.io",
  $SitecoreArchive = "Sitecore 9.3.0 rev. 003498 (OnPrem)_single.scwdp.zip",
  $XConnectArchive = "Sitecore 9.3.0 rev. 003498 (OnPrem)_xp0xconnect.scwdp.zip",
  $IdentityArchive = "Sitecore.IdentityServer 4.0.0 rev. 00257 (OnPrem)_identityserver.scwdp.zip",
  $PowerShellArchive = "PowerShell-7.0.2-win-x64.zip",
  $SqlExe = "SQLServer2019-DEV-x64-ENU.exe",
  $JavaVersion = "8u252",
  $JavaUrlVersion = "8u252b09",
  $SolrBaseUrl = "https://archive.apache.org/dist/lucene/solr",
  [switch]$Dependencies = $false,
  [switch]$Builder = $false,
  [switch]$Installer = $false,
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
  $sitecoreResourcesPath = ".\resources\sitecore"
  $xconnectResourcesPath = ".\resources\xconnect"
  $identityResourcesPath = ".\resources\identity"
  
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
  $builderBuildArgs += "."
  Start-Process docker -ArgumentList $builderBuildArgs -NoNewWindow -Wait 
  Pop-Location
}

# build installer image
if ($Installer) {
  Push-Location .\installer\
  $installerTag = "installer:$SitecoreVersion-$WindowsVersion"
  $installerBuildArgs = $buildArgs
  $installerBuildArgs += "-t $installerTag"
  $installerBuildArgs += "-t $Registry/$installerTag"
  $installerBuildArgs += "--build-arg WIN_VERSION=$WindowsVersion"
  $installerBuildArgs += "--build-arg SC_VERSION=$SitecoreVersion"
  $installerBuildArgs += "."
  Start-Process docker -ArgumentList $installerBuildArgs -NoNewWindow -Wait 
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
  $solrBuildArgs += "--build-arg JAVA_BASE_URL=""https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk$JavaVersion-b09/OpenJDK8U-jre_x64_windows_$JavaUrlVersion.zip"""
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