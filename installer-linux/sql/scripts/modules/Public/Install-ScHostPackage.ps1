<#
.SYNOPSIS

Installs a Sitecore Host plugin NuGet package to a Sitecore Host instance.

.DESCRIPTION

Sitecore Host plugins are distributed via NuGet packages and have specific requirements to where assets are deployed. This will extract the files and place them in the correct directories depending on whether this is an application plugin or a runtime plugin.

.PARAMETER Path
Specifies the path to the NuGet package (.nupkg) file.

.PARAMETER Path
Specifies the path to the root of the Sitecore Host application.

.PARAMETER Runtime
Set this flag to install the Sitecore Host plugin as a runtime plugin in the sitecoreruntime folder.

.PARAMETER Environment
For runtime plugins only. Specifies the environment for the plugin to be deployed to. Default value is "production".

.INPUTS

None. You cannot pipe objects to Install-ScHostPackage.

.OUTPUTS

None. Files are extracted to their target location and the script produces no output.

.EXAMPLE

C:\PS> Install-ScHostPackage -Path C:\packages\Sitecore.Host.Plugin.1.0.0.nupkg -HostPath C:\inetpub\wwwroot\schost

.EXAMPLE

C:\PS> Install-ScHostPackage -Path C:\packages\Sitecore.Host.Plugin.1.0.0.nupkg -HostPath C:\inetpub\wwwroot\schost -Runtime

.EXAMPLE

C:\PS> Install-ScHostPackage -Path C:\packages\Sitecore.Host.Plugin.1.0.0.nupkg -HostPath C:\inetpub\wwwroot\schost -Runtime -Environment "development"

.LINK

https://github.com/georgechang/sitecore-host-utilities

#>

function Install-ScHostPackage {
	[CmdletBinding(DefaultParameterSetName = "default")]
	param(
		[Parameter(ParameterSetName = "default", Mandatory = $true, Position = 0)]
		[Parameter(ParameterSetName = "runtime", Mandatory = $true, Position = 0)]
		[string]$Path,
		[Parameter(ParameterSetName = "default", Mandatory = $true)]
		[Parameter(ParameterSetName = "runtime", Mandatory = $true)]
		[string]$HostPath,
		[Parameter(ParameterSetName = "runtime", Mandatory = $true)]
		[switch]$Runtime,
		[Parameter(ParameterSetName = "runtime")]
		[string]$Environment = "production"
	)

	Add-Type -AssemblyName System.IO.Compression.FileSystem
	$zip = [System.IO.Compression.ZipFile]::OpenRead($Path)

	$nuspec = $zip.Entries | Where-Object { [IO.Path]::GetExtension($_.FullName) -eq ".nuspec" } | Select-Object Name -First 1
	$name = [System.IO.Path]::GetFileNameWithoutExtension($nuspec.Name)

	$targetLibPath = if ($Runtime) { Join-Path $HostPath "sitecoreruntime/$Environment"	} else { $HostPath }
	$targetSitecorePath = Join-Path $targetLibPath -ChildPath "sitecore/$name"

	# Create missing folders
	if (-not (Test-Path $targetLibPath)) {
		New-Item -Path $targetLibPath -ItemType Directory -Force | Out-Null
	}

	if (-not (Test-Path $targetSitecorePath)) {
		New-Item -Path $targetSitecorePath -ItemType Directory -Force | Out-Null
	}

	# Extract files to proper targets
	foreach ($entry in $zip.Entries) {
		if ($entry.FullName.StartsWith("lib/")) {
			$destination = "$targetLibPath\$($entry.Name)"
		}
		if ($entry.FullName.StartsWith("sitecore/")) {
			$filePath = $entry.FullName -replace "sitecore/", ""
			New-Item -Path (Split-Path $targetSitecorePath\$filePath) -ItemType Directory -Force | Out-Null
			$destination = "$targetSitecorePath\$filePath"
		}
		if ($destination) {
			[System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destination, $true)
		}
		$destination = $null
	}

	$zip.Dispose()
}