function Update-ConfigurationFile
{
	params(
		[string]$Path,
		[string]$XPath,
		[string]$Property,
		[string]$Value
	)

	[xml]$XmlDocument = Get-Content -Path $Path
	$Target = $XmlDocument.SelectSingleNode($XPath)
	$Target.($Property) = $Value
	$XmlDocument.Save()
}