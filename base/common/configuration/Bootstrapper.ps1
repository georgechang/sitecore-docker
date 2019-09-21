param(
	[string]$Path,
	[string]$AppPath,
	[string]$Expression
)

if ($Path) {
	Push-Location $PSScriptRoot
	Import-Module .\Utilities.psm1
	Sync-Configuration -Path $Path -AppPath $AppPath
	Pop-Location
}

if ($Expression) {
	Invoke-Expression $Expression
}