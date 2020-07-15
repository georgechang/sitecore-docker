param(
	[Parameter(Mandatory = $true)]
	[string]$ConfigPath,
	[Parameter(Mandatory = $true)]
	[string]$SolrUrl
)

$tempPath = [System.IO.Path]::GetTempPath()
$tempDirectory = Join-Path $tempPath -ChildPath "/sitecore"
if (Test-Path $tempDirectory) {
	Remove-Item -Path $tempDirectory -Recurse -Force
}
New-Item -Path $tempDirectory -ItemType Directory -Force

Copy-Item "$ConfigPath/*" -Destination "$tempDirectory/" -Recurse
$configContentPath = Join-Path $tempDirectory -ChildPath "/conf/solrconfig.xml"
$configContent = Get-Content -Path $configContentPath -Raw
$configContent -replace "update.autoCreateFields:true", "update.autoCreateFields:false" | Set-Content -Path $configContentPath

$xsltSettings = New-Object System.Xml.Xsl.XsltSettings
$xmlUrlResolver = New-Object System.Xml.XmlUrlResolver
$xsltSettings.EnableScript = 1
$xsltSettings.EnableDocumentFunction = 1

$xmlPath = Join-Path $tempDirectory -ChildPath "/conf/managed-schema"
Rename-Item $xmlPath -NewName "managed-schema-old"
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
$xslt.Load((Join-Path $PSScriptRoot -ChildPath "/managed-schema.xslt"), $xsltSettings, $xmlUrlResolver)
$xslt.Transform((Join-Path $tempDirectory -ChildPath "/conf/managed-schema-old"), $xmlPath)

Invoke-RestMethod "$SolrUrl/solr/admin/configs?action=DELETE&name=sitecore&omitHeader=true"
Compress-Archive (Join-Path $tempDirectory -ChildPath "/conf/*") -DestinationPath (Join-Path $tempDirectory -ChildPath "/sitecore.zip")
Invoke-RestMethod "$SolrUrl/solr/admin/configs?action=UPLOAD&name=sitecore" -Method Post -ContentType "application/octet-stream" -InFile (Join-Path $tempDirectory -ChildPath "/sitecore.zip")
