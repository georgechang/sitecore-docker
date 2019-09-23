param(
	[string]$Path,
	[string]$AppPath,
	[string]$LicensePath,
	[string]$Expression
)

if ($Path) {
	Push-Location $PSScriptRoot
	Import-Module .\Utilities.psm1
	Sync-Configuration -Path $Path -AppPath $AppPath
	Pop-Location
}

if ($LicensePath) {
	Copy-Item -Path "/license/license.xml" -Destination $LicensePath
}

if ($Expression) {
	Invoke-Expression $Expression
}