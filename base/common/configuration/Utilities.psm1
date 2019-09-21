function Sync-Configuration
{
	param(
		[string]$Path,
		[string]$AppPath
	)

	$json = Get-Content $Path | ConvertFrom-Json
	foreach ($config in $json.configuration)
	{
		$path = Join-Path $AppPath -ChildPath $config.path | Resolve-Path
		$config.mappings | % { Update-ConfigurationFile -Path $path -XPath $_.xpath -Property $_.property -Value $ExecutionContext.InvokeCommand.ExpandString($_.value)  }
	}

	# foreach ($certificate in $json.certificates)
	# {
	# 	#$path = Resolve-Path $certificate.path
	# 	Invoke-Expression -Command ".\certoc.exe -ImportPFX -p $($certificate.secret) root $path"
	# }
}
function Update-ConfigurationFile
{
	param(
		[string]$Path,
		[string]$XPath,
		[string]$Property,
		[string]$Value
	)

	[xml]$XmlDocument = Get-Content -Path $Path
	$Target = $XmlDocument.SelectSingleNode($XPath)
	$Target.($Property) = $Value
	$XmlDocument.Save($Path)
}